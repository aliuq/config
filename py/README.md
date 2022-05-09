# Python

## **pyproject.toml**

1. Install [yapf](https://github.com/google/yapf):
	```bash
	pip install yapf
	```

2. Set formatting provider in `settings.json`:
	```json
	{
		"python.formatting.provider": "yapf",
		"[python]": {
			"editor.formatOnSave": true
		},
	}
	```

3. Clone `pyproject.toml` in `.vscode`:
	```bash
	npx degit aliuq/config/py/pyproject.toml pyproject.toml
	```
