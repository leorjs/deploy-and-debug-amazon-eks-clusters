# Deploy and debug Amazon EKS-Cluster
![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/77f0e341-f485-49da-8c15-607bd1214a0d)


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


1. Configure las variables de entorno.


```
export AWS_REGION="us-east-1"
export CLUSTER_NAME="my-fargate"
```

2. Crear un clúster de EKS.

- Para crear un clúster de EKS se utilizara  las especificaciones del archivo clusterconfig-fargate.yaml, ejecute el siguiente comando.

`eksctl create cluster -f clusterconfig-fargate.yaml`

- Resultado del comando

    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/95429351-c2ec-49c4-893d-d1b0425800b8)

    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/58bd603b-eae2-4916-8f8c-a0e5314be684)

- El clusterconfig-farget arroja un Stack en cloudformation:

    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/89b405a1-ff7e-49eb-82ab-368d43029a38)
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/9c1cbdc7-036a-4cfc-be35-a078e42b2545)
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/8e5dfca4-8d1f-423f-9727-a78bc578ce82)


3. Compruebe el clúster creado.

- Vamos a comprobar que el cluster se creo correctamente

  `eksctl get cluster --output yaml`

  - La salida debería verse de la siguiente manera:

  ```
  - Name: my-fargate
    Owned: "True"
    Region: us-east-1
  ```

- Compruebe el perfil de Fargate creado utilizando el CLUSTER_NAME.

  `eksctl get fargateprofile --cluster $CLUSTER_NAME --output yaml`

- Este comando muestra información sobre los recursos. Puede usar la información para verificar el clúster creado. La salida debería ser la siguiente.

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

</details>

<details>
<summary>Implementar un contenedor</summary>  

4. Implementar el servidor web NGINX.

    - Para aplicar la implementación del servidor web de NGINX en el clúster, ejecute el siguiente comando.
    
      ```
      kubectl apply -f ./nginx-deployment.yaml
      ```
    
    - Resultado del comando
    
      ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/3cd9388c-9c0f-4d8e-9f37-1befe34dee1e)
    
    
    - La implementación incluye tres réplicas de la imagen de NGINX tomada de la galería pública de Amazon ECR. La imagen se implementa en el espacio de nombres predeterminado y se expone en el puerto 80 de los pods en ejecución.

5. Compruebe la implementación y los pods.

      ```
      kubectl get deployment
      ```

  - Resultado del comando
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/5dccba95-5b27-41f1-9cd7-3c89a5599392)

  - Verificación de los Pods
  
    ```
    kubectl get pods
    ```
  
  - Resultado del comando
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/e0d3f75c-5b1c-46cb-bc3a-22d83d2e163c)

6. Escale la implementación.

    ```
    kubectl scale deployment nginx-deployment --replicas 4
    ```
  
  - Resultado del comando
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/024fc2e0-8051-4424-8caf-ae74348a2f0a)
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/3b2c2918-08f3-4f6d-9503-09ace9d8debf)


</details>


<details>

<summary>Implementar un controlador del ELB</summary>  

7. Configure las variables de entorno.

  - Adquirimos el nombre de la VPC con el siguiente comando que es necesario esta información más adelante.
  
    ```
    aws cloudformation describe-stacks --stack-name eksctl-$CLUSTER_NAME-cluster --query "Stacks[0].Outputs[?OutputKey==\`VPC\`].OutputValue"
    ```
  
  - Resultado del comando
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/d8089089-cfe2-4264-924b-e90a1b949c88)
  
  - Luego exportalo como variable
  
    ```
    export VPC_ID="vpc-<YOUR-VPC-ID>"
    
    ```

8. Configurar el IAM de una cuenta de servicio del clúster

    ```Command
    eksctl utils associate-iam-oidc-provider \
    --region $AWS_REGION \
    --cluster $CLUSTER_NAME \
    --approve
    ```
  
  - Descargue y cree la política de IAM.
  
    - Descargue una política de IAM para el controlador del equilibrador de carga de AWS que le permita realizar llamadas a las API de AWS en su nombre.
  
      `curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json`
  
    - Cree la política en su cuenta de AWS mediante la CLI de AWS.
    
      ```
      aws iam create-policy \
      --policy-name AWSLoadBalancerControllerIAMPolicy \
      --policy-document file://iam-policy.json
      ```
  
      - Resultados del comando
  
      ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/88b7f711-7098-4f07-962e-ccc34a42461f)
  
  
  > [!NOTE]
  > Guarde el Nombre de recurso de Amazon (ARN) de la política como $POLICY_ARN
  > export POLICY_ARN=”arn:aws:iam::<YOUR-ACCOUNT-ID>:policy/AWSLoadBalancerControllerIAMPolicy”


9.  Cree una cuenta de servicio de IAM.

  - Cree una cuenta de servicio denominada aws-load-balancer-controller en el espacio de nombres kube-system. Utilice el CLUSTER_NAME, AWS_REGION y POLICY_ARN que configuró previamente.
    ```
    eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --region=$AWS_REGION \
    --attach-policy-arn=$POLICY_ARN \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --override-existing-serviceaccounts \
    --approve
    ```
  
  - Resultados:
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/8cce2d63-d3d1-4c2e-9f1e-f6afdb737ef0)
  
  
  - Verifica que todo salio correcto con el siguiente comando
    ```
    eksctl get iamserviceaccount \
    --cluster $CLUSTER_NAME \
    --name aws-load-balancer-controller \
    --namespace kube-system \
    --output yaml
    ```

10. Instalación del complemento ELB controller de AWS.

  - Actualizar el repositorio de Helm.
    
    `helm repo update`
  
  - Añada el repositorio de gráficos de Amazon EKS al repositorio de Helm.
    
    `helm repo add eks https://aws.github.io/eks-charts`
  
  - Aplique las definiciones de recursos personalizados (CRD) de Kubernetes que utiliza el Controlador del equilibrador de carga AWS eks-chart en segundo plano
    
    `kubectl apply -k "https://github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"`
  
  - Resultados:
  
    ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/5f974c8a-f6f6-4e1a-bef8-25c684124943)
  
  - Instale el gráfico de Helm con las variables de entorno que configuró anteriormente.
   
    ```
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
     --set clusterName=$CLUSTER_NAME \
     --set serviceAccount.create=false \
     --set region=$AWS_REGION \
     --set vpcId=$VPC_ID \
     --set serviceAccount.name=aws-load-balancer-controller \
     -n kube-system
    ```

11. Crear un servicio NGINX.
    
  - Cree un servicio para exponer los pods de NGINX mediante el archivo nginx-service.yaml
    
    `kubectl apply -f nginx-service.yaml`
    
12. Cree el recurso de entrada de Kubernetes.
    
  - Cree un servicio para exponer los pods de NGINX mediante el archivo nginx-ingress.yaml
    
    `kubectl apply -f nginx-ingress.yaml`

13. Obtenga la URL del ELB.
  
  - `kubectl get ingress nginx-ingress`
  > [!TIP]
  > Copie la ADDRESS (por ejemplo, k8s-default-nginxing-xxx.us-east-1.elb.amazonaws.com) del resultado y péguela en su navegador para acceder al archivo index.html

</details>

<details>

<summary>Depurar contenedores en ejecución (port-forward)</summary>  

14. Seleccione un pod para hacer el debug.
   
  - Listamos los pods y luego elegimos uno
      `kubectl get pods` 
  
  - Resultados:
    
      ```
        NAME                               READY   STATUS    RESTARTS   AGE
      nginx-deployment-xxxx-aaa      1/1     Running   0          55m
      nginx-deployment-xxxx-bbb      1/1     Running   0          55m
      nginx-deployment-xxxx-ccc      1/1     Running   0          55m
      nginx-deployment-xxxx-ddd      1/1     Running   0          42m
      ```
  
  - Vamos a tomar un POD especifico para esta practica y la exportamo como variable
    
      `export POD_NAME="nginx-deployment-<YOUR-POD-NAME>"`


  - Comando adicional para ver el log del pod
      > `kubectl logs $POD_NAME`
  

15. Reenvíe el puerto NGINX.
  
    - Utilice el reenvío de puertos para asignar el puerto del pod para acceder al servidor web NGINX a un puerto de su máquina local.
      - `kubectl port-forward deployment/nginx-deployment 8080:80`
      
    - En su navegador, abra la siguiente URL.
      - `http://localhost:8080`


      
      > El comando port-forward proporciona acceso al archivo index.html sin ponerlo a disposición del público a través de un equilibrador de carga. Esto resulta útil para acceder a la aplicación en ejecución mientras la depura. Puede detener el reenvío de puertos   pulsando el comando del teclado Ctrl+C.


16. Ejecute comandos dentro del pod.
  
  - Para ver el archivo index.html actual, utilice el siguiente comando.
    - `kubectl exec $POD_NAME -- cat /usr/share/nginx/html/index.html`
    
17. Copie los archivos a un pod.
    
  - Primero eliminamos el index.html que viene por default y luego lo reemplazamos por el nuestro
    - `kubectl exec $POD_NAME -- rm /usr/share/nginx/html/index.html`
    
- Cargue el archivo index.html local personalizado en el pod.
    - `kubectl cp index.html $POD_NAME:/usr/share/nginx/html/`
    
18. Utilice el reenvío de puertos para mostrar el cambio.
    - Utilice el reenvío de puertos para verificar los cambios que realizó en este pod.
      `kubectl port-forward pod/$POD_NAME 8080:80`
    
      ![image](https://github.com/leorjs/deploy-and-debug-amazon-eks-clusters/assets/119978221/443bd9a3-7f08-4864-be61-f3eade65f8df)


</details>

<details>

<summary>Eliminar recursos</summary>  

19. Para eliminar toda la infraestructura creada, cree un script.

  - Abrir el archivo y cambiar las variables necesarias, importante recordar que deben siempre tener los export de:
    
    - $CLUSTER_NAME
    - $AWS_REGION
    - $POLICY_AR
      
  - Darle permiso de ejecución: `chmod +x cleanup.sh`
  - Luego lo ejecutas: `sh cleanup.sh`

</details>

<details>
  
<summary>Solución de problemas</summary>  

- En construcción
  
</details>

