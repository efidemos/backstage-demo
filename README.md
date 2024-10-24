# Getting started
1. Get secret `arn:aws:secretsmanager:eu-north-1:585466297447:secret:efidemos/github-app-backstage-efidemos-credentials-UcJd33` from AWS `devops-test` account and save as `github-app-backstage-efidemos-credentials.yaml` in repo root.
2. Update `docker-compose.yaml` with the values for `clientId` and `clientSecret` from the file saved above.
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