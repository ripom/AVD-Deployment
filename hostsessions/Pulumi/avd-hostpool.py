"""An Azure RM Python Pulumi program"""
import pulumi
from pulumi_azure_native import storage
from pulumi_azure_native import resources
import pulumi_azure_native as azure_native
import datetime

#Import the parameter values from Stack config
config=pulumi.Config()
rg=config.require('rg')
hostpoolName=config.require('hostpoolName')
hostpoolType=config.require('hostpoolType')
hostpoolLB=config.require('hostpoolLB')
hostpoolMaxSession=int(config.require('hostpoolMaxSession'))
hostpoolDeskAssign=config.require('hostpoolDeskAssign')
hostpoolAppGroupType=config.require('hostpoolAppGroupType')
tagName1=config.require('tagName1')
tagValue1=config.require('tagValue1')
workspaceDescription=config.require('workspaceDescription')
workspaceFriendlyName=config.require('workspaceFriendlyName')
workspaceName=config.require('workspaceName')
vmPrefixName=config.require('vmPrefixName')
maxVM=int(config.require('maxVM'))
sizeVM=config.require('sizeVM')
subnetID=config.require('subnetID')
VMusername=config.require('VMusername')
VMpassword=config.require('VMpassword')
publisher=config.require('publisher')
offer=config.require('offer')
sku=config.require('sku')
version=config.require('version')

# Create an Azure Resource Group
resource_group = resources.ResourceGroup(rg, 
    tags={
        tagName1: tagValue1,
    },    
    resource_group_name=rg)

#Generate a new date adding 24 hours from now
dt=(datetime.datetime.now()+datetime.timedelta(hours=24)).isoformat()

#Create an AVD HostPool
host_pool = azure_native.desktopvirtualization.HostPool(
    resource_name=hostpoolName,
    friendly_name=hostpoolName,
    host_pool_name=hostpoolName,
    host_pool_type=hostpoolType, 
    load_balancer_type=hostpoolLB,
    location=resource_group.location,
    max_session_limit=hostpoolMaxSession,
    personal_desktop_assignment_type=hostpoolDeskAssign,
    preferred_app_group_type=hostpoolAppGroupType,
    resource_group_name=resource_group.name,
    start_vm_on_connect=False,
    registration_info=azure_native.desktopvirtualization.RegistrationInfoArgs(
        expiration_time=dt,
        registration_token_operation="Update",
    ),
    tags={
        tagName1: tagValue1,
    }
)
#Get the registration token key
registrationToken=host_pool.registration_info.token
#Send the registration token key in output
pulumi.export('RegistrationToken', host_pool.registration_info.token)
#Create an AVD Workspace
workspace = azure_native.desktopvirtualization.Workspace(workspaceName,
    description=workspaceDescription,
    friendly_name=workspaceFriendlyName,
    location=resource_group.location,
    resource_group_name=resource_group.name,
    tags={
        tagName1: tagValue1,
    },
    workspace_name=workspaceName)

#Look to create maxVM resources
for x in range(0, maxVM):
    #Create a VM Nic
    network_interface = azure_native.network.NetworkInterface(vmPrefixName+"-nic-"+str(x),
        #enable_accelerated_networking=True,
        tags={
            tagName1: tagValue1,
        },
        ip_configurations=[azure_native.network.NetworkInterfaceIPConfigurationArgs(
            name="ipconfig1",
            subnet=azure_native.network.SubnetArgs(
                id=subnetID,
            ),
        )],
        location=resource_group.location,
        network_interface_name=vmPrefixName+"-nic-"+str(x),
        resource_group_name=resource_group.name)
    #Create a VM from a marketplace Image using Premium disk
    virtual_machine = azure_native.compute.VirtualMachine(vmPrefixName+"-"+str(x),
        tags={
            tagName1: tagValue1,
        },        
        hardware_profile=azure_native.compute.HardwareProfileArgs(
            vm_size=sizeVM,
        ),
        location=resource_group.location,
        network_profile=azure_native.compute.NetworkProfileArgs(
            network_interfaces=[azure_native.compute.NetworkInterfaceReferenceArgs(
                id=network_interface.id, 
                primary=True,
            )],
        ),
        os_profile=azure_native.compute.OSProfileArgs(
            admin_password=VMpassword,
            admin_username=VMusername,
            computer_name=vmPrefixName+"-"+str(x),
            windows_configuration={
                "enableAutomaticUpdates": True,
                "patchSettings": azure_native.compute.PatchSettingsArgs(
                    assessment_mode="ImageDefault",
                ),
                "provisionVMAgent": True,
            },
        ),
        resource_group_name=resource_group.name,
        storage_profile=azure_native.compute.StorageProfileArgs(
            image_reference=azure_native.compute.ImageReferenceArgs(
                publisher=publisher,
                offer=offer,
                sku=sku,
                version=version,
            ),
            os_disk={
                "caching": azure_native.compute.CachingTypes.READ_WRITE,
                "createOption": "FromImage",
                "managedDisk": azure_native.compute.ManagedDiskParametersArgs(
                    storage_account_type="Premium_LRS",
                ),
                "name": vmPrefixName+"-osDisk-"+str(x),
            },
        ),
        vm_name=vmPrefixName+"-"+str(x))
    # Join the VM to Azure AD
    vmextensionaadjoin=azure_native.compute.VirtualMachineExtension(resource_name='vmAADjoinextension-'+str(x),
        opts=pulumi.ResourceOptions(depends_on=[virtual_machine]),
        location=resource_group.location,
        publisher='Microsoft.Azure.ActiveDirectory',
        resource_group_name=resource_group.name,
        type='AADLoginForWindows',
        type_handler_version='1.0',
        vm_extension_name="vmAADjoinextension"+str(x),
        vm_name=vmPrefixName+"-"+str(x))
    #Install the RDagent and Register the VM to the HostPool
    virtual_machine_run_command_by_virtual_machine = azure_native.compute.VirtualMachineRunCommandByVirtualMachine("vMRunCommand-"+str(x),
        async_execution=False,
        opts=pulumi.ResourceOptions(depends_on=[virtual_machine]),
        location=resource_group.location,
        parameters=[
            {
                "name": 'registrationToken',
                "value": registrationToken
            },

        ],
        resource_group_name=resource_group.name,
        run_command_name="myRunCommand",
        source=azure_native.compute.VirtualMachineRunCommandScriptSourceArgs(
            script='''param([string]$registrationToken)
            Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH -o $pwd\\RDagentBootLoader.msi -useBasicParsing
            Unblock-File -path  $pwd\\RDagentBootLoader.msi; msiexec /i $pwd\\RDAgentBootLoader.msi /quiet
            Invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv -o $pwd\\RDagent.msi -useBasicParsing; Unblock-File -path $pwd\\RDagent.msi
            msiexec /i $pwd\\RDAgent.msi /quiet REGISTRATIONTOKEN=$registrationToken''',
                                    
        ),
        vm_name=vmPrefixName+"-"+str(x))

#test ad join
# compute.VirtualMachineExtension('join-ad-domain-extension',
#     resource_group_name=resource_group.name,
#     virtual_machine_name=vm.name,
#     publisher='Microsoft.Compute',
#     type='JsonADDomainExtension',
#     type_handler_version='1.3',
#     settings={
#         "Name": "mydomain.com",
#         "User": "admin@mydomain.com",
#         "OUPath": "OU=MyOU,DC=mydomain,DC=com",
#         "Restart": "true"
#     },
#     protected_settings={
#         "Password": pulumi.secret("Password1234!")
#     })