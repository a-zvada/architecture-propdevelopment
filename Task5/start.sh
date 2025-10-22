#!/bin/bash

# Применение сетевых политик
kubectl apply -f network-policies.yaml

# Создание namespace crm, если он не существует
kubectl create namespace crm --dry-run=client -o yaml | kubectl apply -f -

# Запуск подов
kubectl run front-end-pod --image=nginx --labels app=front-end --port=443 --namespace=crm --expose --restart=Never
kubectl run back-end-api-pod --image=nginx --labels app=back-end-api --port=443 --namespace=crm --expose --restart=Never
kubectl run admin-front-end-pod --image=nginx --labels app=admin-front-end --port=443 --namespace=crm --expose --restart=Never
kubectl run admin-back-end-api-pod --image=nginx --labels app=admin-back-end-api --port=443 --namespace=crm --expose --restart=Never
