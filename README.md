# Getting started

1. Get secret `arn:aws:secretsmanager:eu-north-1:585466297447:secret:efidemos/github-app-backstage-efidemos-credentials-UcJd33` from AWS `devops-test` account and save as `github-credentials.yaml` in `src` directory (it should match the structure of github-app-backstage-efidemos-credentials.yaml).

2. Set environement with values (to be consumed by docker-compose):
  - GITHUB_CLIENTID
  - GITHUB_CLIENTSECRET
  - GITHUB_USER (your GitHub account name)
  Linux example `export GITHUB_CLIENTID="my_client_id"`

3. In `src/examples/org.yaml` add a User entity for your own GitHub handle, e.g.:
    ```
    ---
    apiVersion: backstage.io/v1alpha1
    kind: User
    metadata:
        name: <GitHub username>
    spec:
        memberOf: [owners]
    ```

4. Run `./build.sh`

5. Profit

## OPA Policy Flow

1. Create policy files at /plugins/opa/policies/(**)/*.rego
2. If already running, you need to fully reboot the OPA server, meaning stop and remove via:
  `docker compose stop opa`
  `docker compose rm opa`
  `docker compose up -d opa`
3. Verify the endpoints via: `curl "http://localhost:8181/v1/data/[package_name]/[value]`, for example
`curl "http://localhost:8181/v1/data/example/greeting` should print the message contained in plugins/opa/policies/example.rego