#!/usr/bin/env nu

source  scripts/kubernetes.nu
source  scripts/common.nu
source  scripts/ingress.nu

def main [] {}

def "main setup" [] {

    rm --force .env

    let provider = main get provider

    main create kubernetes $provider

    let ingress_data = (
        main apply ingress --provider $provider
    )

    kubectl create namespace a-team

    apply gitops_promoter $"promoter-webhook-receiver.($ingress_data.host)"

    main print source
    
}

def "main destroy" [
    provider: string
] {

    main destroy kubernetes $provider
}

def "apply gitops_promoter" [
    webhook_host: string
] {

    (
        kubectl apply
            --filename https://github.com/argoproj-labs/gitops-promoter/releases/download/v0.0.1-rc5/install.yaml
    )

    open ingress.yaml |
        upsert spec.rules.0.host $webhook_host |
        save ingress.yaml --force

    (
        kubectl --namespace promoter-system apply
            --filename ingress.yaml
    )

}
