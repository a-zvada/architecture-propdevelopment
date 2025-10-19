#!/bin/bash

# Функция для создания пользователя
create_user() {
  USER=$1
  GROUP=$2

  # Генерация приватного ключа
  openssl genrsa -out ${USER}.key 2048

  # Генерация CSR
  openssl req -new -key ${USER}.key -out ${USER}.csr -subj "/CN=${USER}/O=${GROUP}"

  # Кодирование CSR в base64
  CSR_BASE64=$(cat ${USER}.csr | base64 | tr -d "\n")

  # Создание YAML для CertificateSigningRequest
  cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${USER}-csr
spec:
  request: ${CSR_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
EOF

  # Одобрение CSR
  kubectl certificate approve ${USER}-csr

  # Получение подписанного сертификата
  kubectl get csr ${USER}-csr -o jsonpath='{.status.certificate}' | base64 --decode > ${USER}.crt

  # Получение CA сертификата кластера
  kubectl get secret -n kube-system -o jsonpath="{.items[?(@.type=='kubernetes.io/service-account-token')].data['ca\.crt']}" | base64 --decode > ca.crt

  # Создание kubeconfig
  kubectl config set-cluster my-cluster --server=https://kubernetes-api-server:6443 --certificate-authority=ca.crt --embed-certs=true --kubeconfig=${USER}-kubeconfig
  kubectl config set-credentials ${USER} --client-certificate=${USER}.crt --client-key=${USER}.key --embed-certs=true --kubeconfig=${USER}-kubeconfig
  kubectl config set-context ${USER}-context --cluster=my-cluster --user=${USER} --kubeconfig=${USER}-kubeconfig
  kubectl config use-context ${USER}-context --kubeconfig=${USER}-kubeconfig

  echo "Пользователь ${USER} создан. Kubeconfig: ${USER}-kubeconfig"
}

# Создание пользователей
create_user "admin-user" "admins"
create_user "viewer-user" "viewers"
create_user "editor-user" "editors"

# Очистка временных файлов
rm *.csr ca.crt