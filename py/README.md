# Python

## **pyproject.toml**

+ Install [yapf](https://github.com/google/yapf):

	```bash
	pip install yapf
	```

+ Install `pyproject.toml` deps module `toml`:

	```bash
	pip install toml
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

+ Clone `pyproject.toml`:

	```bash
	npx degit aliuq/config/py/pyproject.toml pyproject.toml
	```

+ See more in [`style.py`](https://github.com/google/yapf/blob/main/yapf/yapflib/style.py)
