# Getting started

1. Get secret `arn:aws:secretsmanager:eu-north-1:585466297447:secret:efidemos/github-app-backstage-efidemos-credentials-UcJd33` from AWS `devops-test` account and save as `github-credentials.yaml` in `src` directory (it should match the structure of github-app-backstage-efidemos-credentials.yaml).

2. Set environement with values (to be consumed by docker-compose):
  - GITHUB_CLIENTID
  - GITHUB_CLIENTSECRET
  - GITHUB_USER (your GitHub account name)
  Linux example `export GITHUB_CLIENTID="my_client_id"`

3. Building: `./build.sh`

    - Will create a container named `backstage` - containing both the backend and frontend (app) packages
    - The image uses app-config.production.yaml
    - Compiles TypeScript (`yarn tsc`)
    - Will inject your $GITHUB_USER into src/examples/org.yaml (and allow authentication via GitHub)

4. Running:
  - local dev with quick iterations (no image rebuild required and uses embedded DB):
    from repo root: `./run.sh`
  - local dev with prod config (requires image rebuild via build.sh, and uses Postgres container)
    from repo root: `./run.sh prod`

5. Profit

## OPA Policy Flow

1. Create policy files at /plugins/opa/policies/(**)/*.rego
2. If already running, you need to fully reboot the OPA server by running the `opa_restart.sh` script.
3. Verify the endpoints via: `curl "http://localhost:8181/v1/data/[package_name]/[value]`, for example
`curl "http://localhost:8181/v1/data/example/greeting` should print the `greeting` variable contained in plugins/opa/policies/example.rego

### Troubleshooting:
 - If the container doesn't stay running, there is likely a .rego syntax error.
   run `docker compose logs opa` to see the error
   iterate quickly using either `opa_restart.sh` helper script, or installing opa cli locally (followed by `opa run --server plugins/opa/policies`) 