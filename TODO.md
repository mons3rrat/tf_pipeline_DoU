TODO:
=====
### tf_pipeline_DoU:

- [ ] Create Readme file
- [x] Add Java Application
- [x] Run Unittest in docker multi-stage build
- [ ] include Parallel steps for docker and terraform
- [ ] integrate sonar cube
- [ ] improvement: pipeline step to check if terraform files are fmted
- [ ] improvement: if there is not diff in plan step, don't ask for approval and skip apply step.

### shared_library:

- [ ] Create Readme file

### jenkins_with_slave_CI_CD:

- [ ] Create Readme file
- [ ] Use AWS KMS and S3 service to encrypt sensible data and have one click jenkins deployment.
- [ ] Create terraform definitions to deploy in AWS. 
- [ ] Improvement: generate jenkins secrets with hashicorp vault