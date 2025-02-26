#!/usr/bin/env nu

source  scripts/kubernetes.nu
source  scripts/common.nu

def main [] {}

def "main setup" [] {

    rm --force .env

    main create kubernetes kind

    kubectl create namespace a-team

    main print source
    
}
