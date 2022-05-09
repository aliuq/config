# Python

## **pyproject.toml**

+ Install [yapf](https://github.com/google/yapf):

	```bash
	pip install yapf
	```

+ Set formatting provider in `settings.json`:

	```json
	{
	  "python.formatting.provider": "yapf",
	  "[python]": {
		  "editor.formatOnSave": true
	  },
	}
	```

+ Clone `pyproject.toml` in `.vscode`:

	```bash
	npx degit aliuq/config/py/pyproject.toml pyproject.toml
	```
