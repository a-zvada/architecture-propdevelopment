#!/bin/bash

kubectl apply -f roles.yaml

echo "Роли созданы: cluster-admin-role, cluster-viewer-role, cluster-editor-role"