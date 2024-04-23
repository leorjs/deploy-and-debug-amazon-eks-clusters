#!/bin/bash

# Asegúrate de definir las variables de entorno necesarias antes de ejecutar este script.
# Por ejemplo:
# export CLUSTER_NAME="my-fargate"
# export AWS_REGION="us-east-1"
# export POLICY_ARN="arn:aws:iam::123456789012:policy/tu-politica"

echo "Iniciando el proceso de limpieza..."

# Eliminar Ingress
kubectl delete ingress/nginx-ingress
echo "Ingress nginx eliminado correctamente."

# Eliminar Servicio
kubectl delete service/nginx-service
echo "Servicio nginx eliminado correctamente."

# Eliminar Helm release
helm delete aws-load-balancer-controller -n kube-system
echo "Helm release aws-load-balancer-controller eliminado correctamente."

# Eliminar IAM service account usando eksctl
eksctl delete iamserviceaccount --cluster $CLUSTER_NAME --namespace kube-system --name aws-load-balancer-controller
echo "IAM service account aws-load-balancer-controller eliminado correctamente."

# Eliminar Deployment
kubectl delete deploy/nginx-deployment
echo "Deployment nginx eliminado correctamente."

# Eliminar EKS Cluster
eksctl delete cluster --name $CLUSTER_NAME
echo "EKS cluster $CLUSTER_NAME eliminado correctamente."

# Eliminar IAM Policy
aws iam delete-policy --policy-arn $POLICY_ARN
echo "IAM policy con ARN $POLICY_ARN eliminada correctamente."

echo "Proceso de limpieza completado."

