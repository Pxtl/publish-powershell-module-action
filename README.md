## Publish PowerShell Module

This GitHub Action enables you to publish a PowerShell module to the [PowerShell Gallery](https://powershellgallery.com).

Forked from [pcgeek86/publish-powershell-module-action](https://github.com/pcgeek86/publish-powershell-module-action)

## Usage

1. Add a GitHub Actions Workflow configuration to your GitHub project, for example `.github/workflows/main.yml`
2. Configure a secret on your GitHub repository, containing your PowerShell Gallery NuGet API key.
3. Add the `publish-powershell-module-action` step to your GitHub Actions job

For example, if you named your secret `PS_GALLERY_KEY`:

```
      - name: Publish Module to PowerShell Gallery
        uses: Pxtl/publish-powershell-module-action@v1
        id: publish-module
        with:
          NuGetApiKey: ${{ secrets.PS_GALLERY_KEY }}
```
### Parameters

The action accepts the following parameters that can be provided in the "with" block.
- **NuGetApiKey** (string, mandatory) - as mentioned above, this should contain your secret NuGet API key.
- **ModulePath** (string, optional, default empty) - the path to the module directory you wish to deploy. If not provided,
  it will attempt publish all directories that contain a .psd1 file that matches the directory name.
- **ContinueIfAlreadyPublished** (bool, optional, default `false`) - if enabled, will continue to publish other modules
  and will report success if a publish fails with the error that the module has already been published.  The error will
  be logged as a warning.  This allows you to run the publish action regardless of whether you're releasing a new version
  or not.  It is particularly useful if you're running a multi-module monorepo.

## Assumptions

* You're writing a PowerShell script module (not a compiled module)
* Your module is contained within a subfolder of your GitHub repository
