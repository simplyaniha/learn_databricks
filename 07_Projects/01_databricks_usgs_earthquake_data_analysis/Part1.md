
# Comprehensive Step-by-Step Guide: End-to-End Data Engineering Project with Azure Databricks

This guide provides a complete walkthrough for building a medallion architecture (Bronze-Silver-Gold) data pipeline entirely within Azure Databricks, processing earthquake data from an API.


## Project Overview

### Business Case

Government agencies, research institutions, and insurance companies need up-to-date earthquake data to:

- Plan emergency responses
- Assess risks for infrastructure planning
- Calculate insurance premiums based on seismic risk
- Make data-driven decisions about building codes and safety measures

### What You'll Build

A fully automated data pipeline that:

- Extracts earthquake data from a public API
- Processes data through Bronze → Silver → Gold layers
- Stores processed data in Azure Data Lake Storage
- Runs on a scheduled trigger (daily)
- Uses only Databricks for orchestration (no Azure Data Factory needed)

---

## Prerequisites

### Required Accounts

- **Microsoft Azure Account** (free trial with $200 USD credits)
    - Search "Microsoft Azure" and sign up for free trial
    - Get 30 days of credits plus free services

### Knowledge Requirements

- Basic Python programming
- Understanding of data transformations
- Familiarity with JSON and API concepts

### Cost Considerations

- **Pay-as-you-go model**: Only charged when resources are actively running
- Use smallest compute instances to minimize costs
- Set cluster auto-termination to avoid unnecessary charges

---

## Architecture Overview

### Medallion Architecture Layers

```
API → Bronze (Raw) → Silver (Cleaned) → Gold (Business-Ready)
```

**Bronze Layer:**

- Raw data exactly as received from API
- Stored as JSON files
- One file per day
- No transformations applied

**Silver Layer:**

- Cleaned and validated data
- Restructured for easier processing
- Missing/null values handled
- Stored as Parquet files
- Data appended daily to single file

**Gold Layer:**

- Business-level aggregates
- Enhanced with reverse geocoding (country codes)
- Significance classifications (Low/Moderate/High)
- Ready for visualization and analytics
- Stored as Parquet files

---

## Setup Azure Resources

### Step 1: Create Azure Databricks Workspace

1. **Navigate to Azure Portal**
    
    - Go to portal.azure.com
    - Sign in with your Azure account
2. **Create Databricks Service**
    
    - Search "Azure Databricks" in top search bar
    - Click "Create" or "Azure Databricks"
    - Click "Create" button
3. **Configure Databricks Workspace**
    
    - **Subscription**: Select your Azure subscription
    - **Resource Group**: Create new → Name it `data-look-db`
    - **Workspace Name**: `data-look-tv` (or your preferred name)
    - **Region**: East US (or your preferred region)
    - **Pricing Tier**: **Premium** (required for Role-Based Access Control)
    - Click "Review + Create"
    - Click "Create"
4. **Wait for Deployment**
    
    - Deployment takes 2-5 minutes
    - Databricks creates its own managed resource group for compute resources

### Step 2: Create Storage Account

1. **Navigate to Storage Accounts**
    
    - Search "Storage Account" in Azure Portal
    - Click "Create"
2. **Configure Storage Account**
    
    - **Subscription**: Same as Databricks
    - **Resource Group**: `data-look-db` (same as Databricks)
    - **Storage Account Name**: `datalookdbstorage` (must be globally unique, lowercase only)
    - **Region**: East US (same as Databricks)
    - **Primary Service**: Select **Azure Data Lake Storage Gen2**
    - **Performance**: Standard
    - **Redundancy**: LRS (Locally Redundant Storage) - sufficient for learning projects
3. **Enable Hierarchical Namespace**
    
    - Click "Next" to Advanced tab
    - **Enable hierarchical namespace**: ✓ Check this box (CRITICAL for Data Lake functionality)
4. **Create Storage Account**
    
    - Click "Review + Create"
    - Click "Create"
    - Deployment completes in under 1 minute

### Step 3: Create Storage Containers

1. **Navigate to Storage Account**
    
    - Go to your storage account resource
    - Click "Containers" in left menu under "Data storage"
2. **Create Three Containers**
    
    **Container 1 - Bronze:**
    
    - Click "+ Container"
    - Name: `bronze`
    - Click "Create"
    
    **Container 2 - Silver:**
    
    - Click "+ Container"
    - Name: `silver`
    - Click "Create"
    
    **Container 3 - Gold:**
    
    - Click "+ Container"
    - Name: `gold`
    - Click "Create"

---

## Configure Security & Access

### Understanding Security Architecture

**Security Principles:**

- **Principle of Least Privilege**: Give only the minimum access needed
- **Role-Based Access Control (RBAC)**: Assign permissions through roles, not directly
- **Managed Identity**: Azure-managed service credentials (no manual password management)

**Connection Requirements:**

- Databricks and Storage Account are completely separate services
- Must explicitly connect them for communication
- Two-way security configuration required:
    - Storage Account side: IAM (Identity and Access Management)
    - Databricks side: Unity Catalog External Data

### Step 1: Locate Databricks Managed Identity

1. **Find Managed Resource Group**
    
    - Go to your Databricks workspace resource
    - Note the "Managed Resource Group" name (e.g., `databricks-rg-...`)
    - Click on the managed resource group link
2. **Identify Access Connector**
    
    - In the managed resource group, find: **"Access Connector for Azure Databricks"**
    - Click on it
    - **Copy the Resource ID** (you'll need this multiple times)
    - Format: `/subscriptions/.../resourceGroups/.../providers/Microsoft.Databricks/accessConnectors/...`

### Step 2: Assign Storage Permissions

1. **Navigate to Storage Account IAM**
    
    - Go to your storage account
    - Click "Access Control (IAM)" in left menu
    - Click "Role assignments" tab
2. **Add Role Assignment**
    
    - Click "+ Add" → "Add role assignment"
3. **Select Role**
    
    - Search for: `Storage Blob Data Contributor`
    - Click on the role to select it
    - Click "Next"
4. **Assign Access**
    
    - **Assign access to**: Select "Managed Identity"
    - Click "+ Select members"
    - **Managed Identity**: Select "Access Connector for Azure Databricks"
    - Find your connector (use Resource ID to verify correct one if multiple exist)
    - Click "Select"
    - Click "Review + assign"
    - Click "Review + assign" again to confirm

**What This Does:**

- Grants Databricks read and write permissions to your storage account
- Uses managed identity (no passwords to manage)
- Follows Azure best practices for service-to-service authentication

![[Pasted image 20251015055040.png]]

### Step 3: Configure Databricks Unity Catalog

1. **Launch Databricks Workspace**
    
    - Go back to your Databricks workspace resource
    - Click "Launch Workspace"
    - Sign in with your Azure credentials (Entra ID/Azure Active Directory)
2. **Navigate to Catalog**
    
    - In Databricks workspace, click "Catalog" in left sidebar
    - Click "External Data"
3. **Create Storage Credential**
    
    - Click "Credentials" tab
    - Click "Create Credential"
    - **Credential Type**: Managed Identity
    - **Credential Name**: `data-look-db`
    - **Access Connector ID**: Paste the Resource ID you copied earlier
    - Click "Create"
4. **Create External Locations (Bronze)**
    
    - Go back to "External Data"
    - Click "External Locations" tab
    - Click "Create External Location"
    - **External Location Name**: `bronze`
    - **URL Format**: `abfss://bronze@<storage-account-name>.dfs.core.windows.net/`
    - Replace `<storage-account-name>` with your actual storage account name
    - **Storage Credential**: Select `data-look-db`
    - Click "Create"
5. **Test Connection**
    
    - After creation, click "Test Connection"
    - Should show all tests passed
    - If empty container warning appears, that's normal (containers are empty)
6. **Repeat for Silver and Gold**
    
    **Silver Location:**
    
    - Name: `silver`
    - URL: `abfss://silver@<storage-account-name>.dfs.core.windows.net/`
    - Credential: `data-look-db`
    
    **Gold Location:**
    
    - Name: `gold`
    - URL: `abfss://gold@<storage-account-name>.dfs.core.windows.net/`
    - Credential: `data-look-db`

---
