# Installation
## Prerequisite
Ensure that Python 3 is installed on the target machine before proceeding with the installation. You can check if Python 3 is installed by running:

```bash
python3 --version
```
1. Clone this repository to the target machine running on Ubuntu
2. `cd` to cloned directory
3. Run `sudo chmod u+x install.sh`
4. Run `sudo ./install.sh`
You're good to go! Metrics will be available on http://localhost:8000/metrics. To test connection to server when using as grafana data source use **/** endpoint.