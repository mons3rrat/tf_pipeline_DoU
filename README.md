TF Pipeline
====

This repo contains a pipeline to test, build and deploy Docker containers on an environment created by Terraform on demand.

![Pipeline](/_docs/tf_pipeline_dou1.png?raw=true)

This repo includes:

* [Dockerfiles](/Dockerfiles): Here you are going to find the Dockerfile used in the pipeline flow. This image is available in Docker Hub [gmlpdou/terraform_hub](https://hub.docker.com/r/gmlpdou/terraform_hub/)
* [app](/app): This directory contains a java application.
* [terraform](/terraform) in this location you going to find the terraform definitions to create on-demand environments.

## How to use this pipeline?


* [Jenkins_with_slave_CI_CD](https://github.com/gmlp/jenkins_with_slave_CI_CD): This repo brings up a Jenkins with all the required plugins.
* [Shared_library](https://github.com/mons3rrat/shared_library): This pipeline requires this shared library.
