#!/bin/bash
set -e

MINIKUBE_VERSION="${MINIKUBE_VERSION}"
KUBERNETES_VERSION="${KUBERNETES_VERSION}"
DRIVER="${DRIVER}"
CPUS="${CPUS}"
MEMORY="${MEMORY}"
DISK_SIZE="${DISK_SIZE}"
CONTAINER_RUNTIME="${CONTAINER_RUNTIME}"

apt-get update
apt-get upgrade -y

if [ "$DRIVER" = "docker" ]; then
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    
    usermod -aG docker ubuntu || true
    systemctl enable docker
    systemctl start docker
fi

curl -LO "https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

if [ "$MINIKUBE_VERSION" = "latest" ]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
else
    curl -LO https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64
fi
chmod +x minikube-linux-amd64
mv minikube-linux-amd64 /usr/local/bin/minikube

if [ "$DRIVER" = "none" ]; then
    minikube start \
        --driver=none \
        --kubernetes-version=${KUBERNETES_VERSION} \
        --cpus=${CPUS} \
        --memory=${MEMORY} \
        --disk-size=${DISK_SIZE} \
        --container-runtime=${CONTAINER_RUNTIME} \
        --apiserver-ips=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
    
    mkdir -p /root/.kube
    minikube kubectl -- config view --raw > /root/.kube/config
    
    mkdir -p /home/ubuntu/.kube
    cp /root/.kube/config /home/ubuntu/.kube/config
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
else
    sudo -u ubuntu bash <<EOF
    minikube start \
        --driver=${DRIVER} \
        --kubernetes-version=${KUBERNETES_VERSION} \
        --cpus=${CPUS} \
        --memory=${MEMORY} \
        --disk-size=${DISK_SIZE} \
        --container-runtime=${CONTAINER_RUNTIME}
    
    # Wait for Minikube to be ready
    minikube status
EOF
    
    sleep 10
    
    mkdir -p /home/ubuntu/.kube
    
    API_PORT=$(docker port minikube | grep 8443 | cut -d':' -f2)
    
    CA_CERT=$(docker exec minikube cat /var/lib/minikube/certs/ca.crt | base64 -w 0)
    CLIENT_CERT=$(docker exec minikube cat /var/lib/minikube/certs/apiserver.crt | base64 -w 0)
    CLIENT_KEY=$(docker exec minikube cat /var/lib/minikube/certs/apiserver.key | base64 -w 0)
    
    cat > /home/ubuntu/.kube/config <<'KUBEEOF'
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $${CA_CERT}
    server: https://127.0.0.1:$${API_PORT}
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate-data: $${CLIENT_CERT}
    client-key-data: $${CLIENT_KEY}
KUBEEOF
    
    sed -i "s|\$${CA_CERT}|$CA_CERT|g" /home/ubuntu/.kube/config
    sed -i "s|\$${CLIENT_CERT}|$CLIENT_CERT|g" /home/ubuntu/.kube/config
    sed -i "s|\$${CLIENT_KEY}|$CLIENT_KEY|g" /home/ubuntu/.kube/config
    sed -i "s|\$${API_PORT}|$API_PORT|g" /home/ubuntu/.kube/config
    
    EXTERNAL_IP=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
    
    cat > /home/ubuntu/.kube/config-external <<'KUBEEOF'
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $${CA_CERT}
    server: https://$${EXTERNAL_IP}:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate-data: $${CLIENT_CERT}
    client-key-data: $${CLIENT_KEY}
KUBEEOF
    
    sed -i "s|\$${CA_CERT}|$CA_CERT|g" /home/ubuntu/.kube/config-external
    sed -i "s|\$${CLIENT_CERT}|$CLIENT_CERT|g" /home/ubuntu/.kube/config-external
    sed -i "s|\$${CLIENT_KEY}|$CLIENT_KEY|g" /home/ubuntu/.kube/config-external
    sed -i "s|\$${EXTERNAL_IP}|$EXTERNAL_IP|g" /home/ubuntu/.kube/config-external
    
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
fi

export KUBECONFIG=/home/ubuntu/.kube/config
kubectl get nodes

sudo -u ubuntu bash <<EOF
export KUBECONFIG=/home/ubuntu/.kube/config
minikube addons enable metrics-server || true
minikube addons enable dashboard || true
minikube addons enable ingress || true
EOF

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

touch /tmp/minikube_setup_complete

echo "Minikube setup completed successfully!"
echo "Local kubeconfig: /home/ubuntu/.kube/config"
echo "External kubeconfig: /home/ubuntu/.kube/config-external"