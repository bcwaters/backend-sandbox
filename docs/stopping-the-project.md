# Stopping the Grok NestJS Microservices Project

This guide explains how to properly stop the Grok NestJS Microservices project and its associated services.

## Stopping the NestJS Application

If you have the NestJS application running in the foreground or background, follow these steps to stop it:

1. If the application is running in the foreground (in your terminal):
   - Press `Ctrl+C` in the terminal where the application is running.

2. If the application is running in the background:
   - Find the process ID:
     ```bash
     ps aux | grep node
     ```
   - Look for the process running your NestJS application and note its PID (Process ID).
   - Kill the process:
     ```bash
     kill <PID>
     ```
   - For a more forceful termination (if needed):
     ```bash
     kill -9 <PID>
     ```

## Stopping Docker Containers

To stop the Docker containers that are running the infrastructure services:

### Stop All Containers

To stop all running containers at once:

```bash
sudo docker-compose down
```

This command will stop and remove all containers defined in your `docker-compose.yml` file.

### Stop Specific Services

If you want to stop only specific services:

```bash
sudo docker-compose stop <service-name>
```

For example:
```bash
sudo docker-compose stop postgres redis
```

### Stop and Remove Everything

If you want to stop all containers and remove all volumes (this will delete all data):

```bash
sudo docker-compose down -v
```

**Warning**: This will delete all data stored in Docker volumes. Use with caution.

## Checking Container Status

To verify that all containers have been stopped:

```bash
sudo docker ps
```

This should show no running containers related to the project.

## Stopping Specific Components

### Database (PostgreSQL)

```bash
sudo docker-compose stop postgres
```

### Cache (Redis)

```bash
sudo docker-compose stop redis
```

### Monitoring Tools

```bash
sudo docker-compose stop prometheus grafana
```

### Logging Tools

```bash
sudo docker-compose stop elasticsearch kibana
```

## Troubleshooting

### Container Won't Stop

If a container refuses to stop with the normal stop command:

```bash
sudo docker-compose kill <service-name>
```

### Port Conflicts After Stopping

If you experience port conflicts after stopping and restarting the project, it might be because some containers didn't stop properly. Check for any running containers:

```bash
sudo docker ps -a
```

And stop any that are still running:

```bash
sudo docker stop <container-id>
```

## Cleaning Up Resources

### Remove Unused Containers

```bash
sudo docker container prune
```

### Remove Unused Volumes

```bash
sudo docker volume prune
```

### Remove Unused Networks

```bash
sudo docker network prune
```

### Complete Cleanup (Use with Caution)

To remove all unused Docker resources (containers, volumes, networks, and images):

```bash
sudo docker system prune -a --volumes
```

**Warning**: This will remove all unused Docker resources, including images. Only use this if you want to completely clean your Docker environment.

## Restarting the Project

After stopping the project, you can restart it by following the instructions in the [Getting Started guide](getting-started.md). 