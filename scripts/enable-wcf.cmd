@echo install the needed Windows IIS features for WCF
dism /Online /Enable-Feature /all /FeatureName:WAS-WindowsActivationService
dism /Online /Enable-Feature /all /FeatureName:WAS-ProcessModel
dism /Online /Enable-Feature /all /FeatureName:WAS-NetFxEnvironment
dism /Online /Enable-Feature /all /FeatureName:WAS-ConfigurationAPI
dism /Online /Enable-Feature /all /FeatureName:WCF-HTTP-Activation
dism /Online /Enable-Feature /all /FeatureName:WCF-HTTP-Activation45

@echo Feature Install Complete
