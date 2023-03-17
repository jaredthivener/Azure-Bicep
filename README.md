# Azure Bicep
This repository contains Azure Bicep projects
<img width="550" alt="fundamentals-bicep-social" src="https://user-images.githubusercontent.com/87688021/210160156-e1a0fb6b-3d59-4a0e-b921-7adf96b9a195.png">
# How to use
The Azure infrastructure is defined using [Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/).

To deploy Azure resources, clone github repo, change directory to project folder and deploy `main.bicep` file. 

Example: 
        `az deployment sub create -l eastus2 -n bicep -f main.bicep`
# Learning
Microsoft Learn
- [Fundamentals of Bicep](https://learn.microsoft.com/en-us/training/paths/fundamentals-bicep/)
- [Intermediate Bicep](https://learn.microsoft.com/en-us/training/paths/intermediate-bicep/)
- [Advanced Bicep](https://learn.microsoft.com/en-us/training/paths/advanced-bicep/)

Optional
- [Deploy Azure resources by using Bicep and Azure Pipelines](https://learn.microsoft.com/en-us/training/paths/bicep-azure-pipelines/)
- [Deploy Azure resources by using Bicep and GitHub Actions](https://learn.microsoft.com/en-us/training/paths/bicep-github-actions/)

YouTube
- [Bicep](https://youtube.com/playlist?list=PLnWpsLZNgHzUWIDWI0lWCTsS8wC9UaJho)
- [Bicep for Real](https://youtube.com/playlist?list=PLeh9xH-kbPPY-6hUKuLKhFu_w2tKFVpl3)
