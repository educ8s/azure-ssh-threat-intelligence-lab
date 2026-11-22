resource "azurerm_resource_group" "honeypot" {
    name     = "rg-honeypot-lab"
    location = "East US" 

tags = {
    Project = "honeypot-lab"
    Owner   = "Nick"
    Environment = "Lab"
    CostCenter = "Portfolio"
    AutoDelete = "Yes"
    }
}