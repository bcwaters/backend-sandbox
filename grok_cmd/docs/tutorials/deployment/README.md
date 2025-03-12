# Deployment Tutorial

## Why Container Orchestration?

Our microservices architecture uses Docker and Kubernetes for deployment and orchestration for several critical reasons:

1. **Docker**
   - Consistent environments
   - Isolated services
   - Easy scaling
   - Efficient resource usage

2. **Kubernetes**
   - Container orchestration
   - Automated deployment
   - Service discovery
   - Load balancing
   - Self-healing capabilities

3. **CI/CD Pipeline**
   - Automated testing
   - Continuous deployment
   - Quality assurance
   - Rapid iteration

## Getting Started

### Docker Setup

1. Create service Dockerfile:
```dockerfile
# Base stage
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "dist/main"]
```

2. Create Docker Compose for local development:
```yaml
version: '3.8'
services:
  api-gateway:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app
      - /app/node_modules
```

### Kubernetes Setup

1. Create namespace:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: microservices
  labels:
    name: microservices
```

2. Create deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: microservices
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
        - name: api-gateway
          image: api-gateway:latest
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: production
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
```

## Implementation Patterns

### Docker Multi-Stage Builds

1. **Development Stage**:
```dockerfile
FROM node:20-alpine AS development

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM node:20-alpine AS production

WORKDIR /app
COPY --from=development /app/dist ./dist
COPY --from=development /app/node_modules ./node_modules
COPY package*.json ./

ENV NODE_ENV=production
CMD ["node", "dist/main"]
```

### Kubernetes Configurations

1. **Service Configuration**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: microservices
spec:
  selector:
    app: api-gateway
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

2. **ConfigMap**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: microservices
data:
  DATABASE_HOST: "postgres-service"
  REDIS_HOST: "redis-service"
  RABBITMQ_HOST: "rabbitmq-service"
```

## Best Practices

1. **Resource Management**:
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

2. **Health Checks**:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Advanced Features

### Kubernetes Features

1. **Horizontal Pod Autoscaling**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

2. **Network Policies**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-gateway-network-policy
spec:
  podSelector:
    matchLabels:
      app: api-gateway
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: auth-service
```

### CI/CD Pipeline

1. **Jenkins Pipeline**:
```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your-registry'
        IMAGE_NAME = 'api-gateway'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm run test'
                sh 'npm run test:e2e'
            }
        }
        
        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }
        
        stage('Docker Push') {
            steps {
                sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
        
        stage('Deploy to K8s') {
            steps {
                sh "kubectl set image deployment/api-gateway api-gateway=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -n microservices"
            }
        }
    }
}
```

## Monitoring

1. **Resource Monitoring**:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: api-gateway-monitor
spec:
  selector:
    matchLabels:
      app: api-gateway
  endpoints:
    - port: metrics
```

2. **Logging**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-gateway
spec:
  containers:
    - name: api-gateway
      volumeMounts:
        - name: varlog
          mountPath: /var/log
    - name: filebeat
      image: docker.elastic.co/beats/filebeat:7.9.3
      volumeMounts:
        - name: varlog
          mountPath: /var/log
  volumes:
    - name: varlog
      emptyDir: {}
```

## Troubleshooting

Common issues and solutions:

1. **Container Issues**
   - Check container logs
   - Verify resource limits
   - Monitor container health

2. **Kubernetes Issues**
   - Check pod status
   - Verify service discovery
   - Monitor node health

3. **Deployment Issues**
   - Review deployment logs
   - Check rollout status
   - Verify configuration

## Production Considerations

1. **High Availability**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

2. **Backup Strategy**:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              image: backup-image
              command: ["backup.sh"]
```

3. **Security**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-gateway
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
    - name: api-gateway
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
``` 