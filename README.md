# debug-app

Debug app to run as pods in Kubernetes.

    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: debug-app
      namespace: default
      labels:
        app: debug-app
    spec:
      selector:
        app: debug-app
      ports:
      - name: app-port
        port: 80
        targetPort: 8080
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: debug-app
      namespace: default
      labels:
        app: debug-app
    spec:
      replicas: 6
      selector:
        matchLabels:
          app: debug-app
      template:
        metadata:
          labels:
            app: debug-app
        spec:
          containers:
          - name: debug-app
            imagePullPolicy: Always
            image: pietervogelaar/debug-app:latest
            ports:
            - containerPort: 8080
