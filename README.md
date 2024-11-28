# Ansible docsite redirect testing

This repository contains a Python script, `url_checker.py` and multiple `*.txt` files that contain url paths.
The `.txt` files are used to construct urls for Ansible community documentation.
The Python script can generate reports in `.txt` and `.csv` format that contain the HTTP status code of each url and, in the case of a redirect, the page to which the url is redirected.

The purpose of the script and `*.txt` files is to evaluate urls and redirect rules for Ansible community documentation to ensure pages return the correct HTTP status code, which should be either `200` or `301`.

## Redirects and pages folders

This repository organizes things into two folders:

- The `redirects` folder contains `.txt` files with url paths based on redirect rules.
- The `pages` folder contains `.txt` files with url paths based on `.html` page names on `docs.testing.ansible.com`.

### Checking redirect rules

Redirect rules are defined in `.htaccess` configuration files in the `ansible/docsite` repository.

- `redirects/ansible_2.3_redirects.txt` corresponds to [ansible/2.3/.htaccess](https://github.com/ansible/docsite/blob/main/ansible/2.3/.htaccess)
- `redirects/ansible_2.4_redirects.txt` corresponds to [ansible/2.4/.htaccess](https://github.com/ansible/docsite/blob/main/ansible/2.4/.htaccess)
- `redirects/ansible_2.5_redirects.txt` corresponds to [ansible/2.5/.htaccess](https://github.com/ansible/docsite/blob/main/ansible/2.5/.htaccess)
- `redirects/ansible_2.6_redirects.txt` corresponds to [ansible/2.6/.htaccess](https://github.com/ansible/docsite/blob/main/ansible/2.6/.htaccess)
- `redirects/ansible_2.9_redirects.txt` corresponds to [ansible/2.9/.htaccess](https://github.com/ansible/docsite/blob/main/ansible/2.6/.htaccess)
- `redirects/ansible_9_redirects.txt` corresponds to [ansible/9/.htaccess](https://github.com/ansible/docsite/blob/main/ansible/9/.htaccess)
- `redirects/ansible_11_redirects.txt` corresponds to [ansible/11/.htaccess](https://github.com/ansible/docsite/blob/main/ansible/11/.htaccess)

Along with the configuration files for specific Ansible versions, there are redirect rules defined in a main `.htaccess` configuration file in the `ansible/docsite` repository.

- `redirects/ansible_devel_redirects.txt` corresponds to rules for the `devel` version in [.htaccess](https://github.com/ansible/docsite/blob/main/.htaccess)
- `redirects/ansible_latest_redirects.txt` corresponds to rules for the `latest` version in [.htaccess](https://github.com/ansible/docsite/blob/main/.htaccess)

Additionally, there are two other files to check redirects for versionless pages and redirect rules that handle links from external sites.

- `redirects/ansible_versionless_redirects.txt` corresponds to rules in [.htaccess](https://github.com/ansible/docsite/blob/main/.htaccess) without any specific version, such as the `/ansible/playbooks_vault.html` page.
- `redirects/external_links.txt` corresponds to redirects for links in external sites.

#### Overview of redirect rules

Each of the redirect rules is similar to the following:

```bash
RedirectMatch "^(/ansible/[^/]+)/plugins/become/doas.html" "$1/collections/community/general/doas_become.html"
```

This rule matches urls that start with `/ansible/` followed by any characters except `/` and then matches the `/plugins/become/doas.html` path. The `$1` back reference then captures the first part, which is a version like `/ansible/2.4`. The url then redirects to the `/collections/community/general/doas_become.html` path.

For example, `/ansible/2.4/plugins/become/doas.html` would redirect to `/ansible/2.4/collections/community/general/doas_become.html`.

#### Testing redirects

The `.txt` files in the `redirects` folder contain the original paths and versions from their corresponding `.htaccess` configuration files.

For example, the `redirects/ansible_2.4_redirects.txt` file contains this path:

```html
/ansible/2.4/playbooks_roles.html
```

This is the path in a url for Ansible 2.4 documentation that should be redirected to some other page. When running the `url-checker.py` script, reports should return either a `301` or `302` HTTP status code. This should indicate that the url is being redirected and the `.htaccess` configuration file is valid.

> Status `301` is preferred because it is a permanent redirect, which is better for SEO authority.

### Checking pages

Pages on `docs.testing.ansible.com` were collected using the `find` command as follows:

```bash
find /var/www/html/path -name "*.html"
```

Running the url checker against `pages/*.txt` returns various HTTP status codes. Expected results for these pages are as follows:

- `ansible/2.3-10` pages should return `301`.
- `ansible/2.9` pages should return `200`.
- `ansible/3-11` pages should return `200`.
- `ansible/devel` pages should return `200` and `301`.
- `landing_pages` should return `200`.

> Ansible 11 pages are the current "latest" version. Testing against `ansible_11` pages produces the same results as the "latest" version.

## Running the url checker

1. Optionally create a Python virtual environment.
2. Install requirements.

   ```bash
   python -m pip install -r requirements.in -c requirements.txt
   ```

3. Run `url_checker.py`.

   ```bash
   # Run against a single text file.
   python url_checker.py --file=path/to/file.txt

   # Run against multiple text files in a directory.
   python url_checker.py --directory=path

   # Check an individual path.
   python url_checker.py --url=/ansible/latest/modules/shell_module.html
   ```

### Generated reports

When you run the url checker, it generates reports in `.txt` and `.csv` format.

```txt
Original Path: /ansible/2.4/playbooks_roles.html
Full URL: https://docs.ansible.com/ansible/2.4/playbooks_roles.html
Status: 302
Redirects to: http://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse.html
Timestamp: YYYY-MM-DD HH:MM:SS
```

- `Original Path:` is the path taken from the `.txt` file or the `url` parameter.
- `Full URL:` is the url that the script constructed from the path and the base hostname.
- `Status:` is the HTTP status code that the url returns. If a redirect rule is in place the code should be `301` for a permanent redirect or `302`.
- `Redirects to:` shows the target url to which the page is redirected.
- `Timestamp:` is self-explanatory.

### Checking target urls

The `.htaccess` configuration file contains the following catch all rule:

```html
RedirectMatch permanent "^/ansible/(2\.(10|[3-7]))/(.+)\.html$" "/ansible/latest/$3.html"
```

This is intended for any pages in versions 2.3 to 2.7 and 2.10 that are not redirected to the general `collections.html`; for example `/ansible/2.3/dev_guide/developing_test_pr.html`. This particular page is not for a plugin or module so it should not be redirected to the collections page.

The catch redirect contains a back reference that redirects to a page with the same name in the latest version. So, with the example above, `/ansible/2.3/dev_guide/developing_test_pr.html` redirects to `/ansible/latest/dev_guide/developing_test_pr.html`.

After generating reports, compile all the paths for target urls into `redirect_targets/.txt` files and then run the url checker against those to look for 404 pages.
