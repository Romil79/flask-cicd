# Flask CI/CD Pipeline

I'm Romil, a fresher DevOps engineer (MCA, MIT World Peace University, Pune), and this is the project I built to actually learn this stuff instead of just putting buzzwords on a resume. It started as a simple Flask app and has slowly turned into an 8-phase pipeline covering containerization, cloud infra, CI/CD, and now Kubernetes.

I've tried to keep every claim in this README honest — if something's marked done, I've actually run it and can demo it. If it's not done yet, I say so.

## What's actually here

- `app.py` - small Flask API, instrumented with Prometheus metrics and a health check endpoint
- `Dockerfile` - containerizes the app
- `docker-compose.yml` - runs the app alongside Prometheus and Grafana locally
- `terraform/` - provisions the EC2 instance this deploys to (ap-south-1)
- `.github/workflows/` - GitHub Actions pipeline: runs tests, builds the Docker image, pushes to Docker Hub, deploys to EC2 over SSH
- `k8s/` - Kubernetes manifests so the same stack can run on Minikube instead of Compose

## Where things stand

**Done (Phases 1-6):**
- Flask app hardened with metrics and a proper health check
- Docker Compose stack with monitoring
- AWS account + IAM set up, CLI configured
- Infrastructure provisioned with Terraform
- CI/CD pipeline deploying to EC2 automatically on push to main
- Kubernetes: same app running on Minikube, with self-healing and rolling updates actually tested (not just configured)

**Not started yet (Phases 7-8):** haven't gotten there. Will update this when I do.

## Phase 6 - Kubernetes

This was the part where I moved everything off Docker Compose and onto a real (if local) Kubernetes cluster. A few things I specifically tested rather than assumed would work:

- Killed a running pod manually and watched Kubernetes recreate it on its own in about 2 seconds - no restart command, no intervention
- Bumped the app's version number and triggered a rolling update, then watched `kubectl get pods` show the old pods terminating and new ones coming up one at a time, never both down together
- Moved the Grafana admin password into a Kubernetes Secret instead of hardcoding it - it's excluded from git, there's a `.example` file showing the structure without the real value

Honestly, getting to this point involved a fair amount of debugging - WSL2 not talking to Docker Desktop properly, a stale git identity, GitHub no longer accepting password auth over HTTPS. None of that is unique to me, but if you're doing this yourself and something breaks halfway through, that's normal, not a sign you're doing it wrong.

### Running it yourself

```bash
minikube start --driver=docker --cpus=4 --memory=6000
eval $(minikube docker-env)
docker build -t flask-app:latest .
kubectl apply -f k8s/
kubectl get pods -n flask-cicd
minikube service flask-service -n flask-cicd --url
```

## A note on secrets

Credentials for the CI/CD pipeline (Docker Hub login, EC2 SSH key, EC2 host) live in GitHub Actions Secrets, not in this repo. `terraform.tfstate` and any `.env` files are gitignored. The Kubernetes Secret for Grafana is excluded too - only a placeholder template is committed.
# trigger
