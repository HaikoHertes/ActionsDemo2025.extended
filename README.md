GitHub Actions and Bicep Deployment Samples
===========================================

This repository contains sample files demonstrating how to utilize GitHub Actions in conjunction with Bicep to deploy resources to Microsoft Azure in a first and simple attempt.

Overview
--------

Bicep is a domain-specific language (DSL) for deploying Azure resources declaratively. By integrating Bicep with GitHub Actions, you can automate your infrastructure deployments, ensuring consistency and reliability. This repository provides examples and workflows to help you get started with this integration.

Contents
--------

*   **.github/workflows/**: Contains GitHub Actions workflow files that define the automation processes.
    
*   **Bicep/**: Holds Bicep templates for deploying various Azure resources.
    

Prerequisites
-------------

Before using the samples in this repository, ensure you have the following:

*   **Azure Subscription**: Active subscription to deploy resources.

*   **Azure Resource Group**: Any resource group to be used for the deployment.
    
*   **GitHub Account**: To set up and run GitHub Actions.
    
*   **Azure Service Principal**: For GitHub Actions to authenticate and deploy resources to Azure.
    

Getting Started
---------------

1.  git clone https://github.com/HaikoHertes/ActionsDemo2025.simple.git your-repo-name
    
2.  **Set Up Azure Credentials**:
    
    *   Create an Azure Service Principal and grant it the necessary permissions (Needs to be Owner on the Resource Group to be used). Use something like
  
        > az ad sp create-for-rbac --name "GitHubActionsDemo" --role Owner --scopes /subscriptions/{PUT-SUB-ID}/resourceGroups/{PUT-RG-NAME} --json-auth
        
    *   Add the following secrets to your GitHub repository using "Settings" / "Secrets and Variables" / "Actions":
        
        *   AZURE\_CREDS (Use the JSON you got from previous step)
            
        *   AZURE\_SUB\_ID
            
3.  **Review and Modify Bicep Templates**:
    
    *   Navigate to the bicep/ directory and review the provided templates.
        
    *   Modify them as needed to fit your specific requirements.
        
4.  **Configure GitHub Actions Workflows**:
    
    *   Examine the workflows in .github/workflows/.
        
    *   Adjust the workflows to reference your Bicep templates and any specific deployment parameters.
        
5.  **Trigger the Workflow**:
    
    *   Push changes to the repository or manually trigger the workflow via the GitHub Actions tab.
        

Resources
---------

*   [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
    
*   [GitHub Actions Documentation](https://docs.github.com/actions)
    
*   [Deploy Azure Resources with Bicep and GitHub Actions](https://docs.microsoft.com/azure/azure-resource-manager/bicep/deploy-github-actions)
    

Contributing
------------

Contributions are welcome! Please fork this repository, make your changes, and submit a pull request.

License
-------

This project is licensed under the MIT License. See the LICENSE file for details.
