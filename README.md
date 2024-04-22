# Deploy and debug Amazon EKS-Cluster
![](./image/eks-deploy.png)

# Resumen

Es un ambiente POC - Pilot creado por la documentación oficial de AWS. Se estará creando un cluster de EKS con el servicio AWS Fargate dentro de la implementación se creará un AWSLoadBalancerController y luego se usara el comando `kubectl port-forward`

## Herramientas
+ Amazon Elastic Kubernetes Service (Amazon EKS)
+ AWS Fargate
+ Elastic Load Balancing (ELB)
+ Helm v3
+ eksctl (última versión)
+ CLI de AWS

<details>
<summary>Crear un clúster de EKS</summary> 

#### 1.- Configure las variables de entorno.


```
export AWS_REGION="us-east-1"
export CLUSTER_NAME="my-fargate"
```

#### 2.- Crear un clúster de EKS.

Para crear un clúster de EKS se utilizara  las especificaciones del archivo clusterconfig-fargate.yaml, ejecute el siguiente comando.

`eksctl create cluster -f clusterconfig-fargate.yaml`

![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/95429351-c2ec-49c4-893d-d1b0425800b8)

![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/58bd603b-eae2-4916-8f8c-a0e5314be684)

El clusterconfig-farget arroja un Stack en cloudformation:
![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/89b405a1-ff7e-49eb-82ab-368d43029a38)
![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/9c1cbdc7-036a-4cfc-be35-a078e42b2545)
![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/8e5dfca4-8d1f-423f-9727-a78bc578ce82)


#### 3.- Compruebe el clúster creado.

3.1.- Vamos a comprobar que el cluster se creo correctamente

`eksctl get cluster --output yaml`

La salida debería verse de la siguiente manera:
```
- Name: my-fargate
  Owned: "True"
  Region: us-east-1
```
3.2.- Compruebe el perfil de Fargate creado utilizando el CLUSTER_NAME.

`eksctl get fargateprofile --cluster $CLUSTER_NAME --output yaml`

3.3.- Este comando muestra información sobre los recursos. Puede usar la información para verificar el clúster creado. La salida debería ser la siguiente.
```
- name: fp-default
  podExecutionRoleARN: arn:aws:iam::<YOUR-ACCOUNT-ID>:role/eksctl-my-fargate-cluster-FargatePodExecutionRole-xxx
  selectors:
  - namespace: default
  - namespace: kube-system
  status: ACTIVE
  subnets:
  - subnet-aaa
  - subnet-bbb
  - subnet-ccc
```
#### 

</details>

<details>
<summary>Implementar un controlador del ELB</summary>  

</details>

<details>
<summary>Depurar contenedores en ejecución (port-forward)</summary>  

</details>

<details>
<summary>Eliminar recursos</summary>  

</details>

<details>
<summary>Solución de problemas</summary>  

</details>

