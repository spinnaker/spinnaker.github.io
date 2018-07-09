
## Jekyll Installation
Swap out `rbenv` below for `rvm` if you prefer. RVM was giving me installation issues, so I found `rbenv` - Travis

1. Create and run from a fresh VM instance:
    1. `gcloud compute instances create jekyll --image-project=ubuntu-os-cloud --image-family=ubuntu-1404-lts --machine-type=n1-standard-1`
    1. `gcloud compute ssh jekyll --ssh-flag="-L 4000:localhost:4000"`
1. Install `rbenv` and `ruby-build`. Add these to `$PATH`:
    1. `sudo apt-get install -y git bzip2 build-essential libssl-dev libreadline-dev zlib1g-dev`
    1. `git clone https://github.com/rbenv/rbenv.git ~/.rbenv`
    1. `git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build`
    1. `echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc`
    1. `echo 'eval "$(rbenv init -)"' >> ~/.bashrc`
    1. `. ~/.bashrc`
1. Install and use ruby 2.4.1    
    1. `rbenv install 2.4.1`
    1. `rbenv global 2.4.1`
1. Fork and clone your forked repo:
    1. `GITHUB_USER=$USER # or something else here`
    1. `git clone https://github.com/$GITHUB_USER/spinnaker.github.io.git`
1. Install `bundle` gem
    1. `cd spinnaker.github.io`
    1. `gem install bundle`
    1. `bundle install`    

## Local Development 
1. Start Jekyll server
    1. `bundle exec jekyll serve --watch`
1. (Optional): Add `--incremental` to speed up page generation when working on one page
    1. `bundle exec jekyll serve --watch --incremental`
1. Navigate to [http://localhost:4000](http://localhost:4000) to see your locally generated page.    

You can do the same within Docker using the included Dockerfile (the volume mount will still allow changes to files to be visible to Jekyll):

```sh
docker build --tag spinnaker/spinnaker.github.io-test .
docker run -it --rm --mount "type=bind,source=$(pwd),target=/code" \
    -p 4000:4000 spinnaker/spinnaker.github.io-test --incremental
```

## Host the website on Amazon S3

1. [Enable static website hosting on a S3 Bucket](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/static-website-hosting.html)
1. `gem install s3_website`
1. `s3_website cfg create`
1. Delete s3_id and s3_secret so that your AWS credentials can be read from ~/.aws/credentials
1. Modify url property at _config.yml to use the CNAME that you want to use
1. `jekyll build`
1. `s3_website push`

## Page Generation

A page named `foo.md` will be transformed to `foo/index.html` and links to `foo` will result in an HTTP 301 
to `foo/`. This has two implications:

1. It is more efficient to include the trailing `/` in links.
2. If you anticipate including resources like images or subpages, create `foo/index.md` instead of `foo.md`.

> During local development, see what's actually generated by browsing the `_site` directory.

## Mermaid

Sequence diagrams can be generated with the [mermaid.js](https://github.com/knsv/mermaid) library by adding `{% 
include mermaid %}` near the bottom of the page. See some of the 
[security docs](https://github.com/spinnaker/spinnaker.github.io/blob/master/setup/security/authentication/index.md)
for an example.

## Breadcrumbs

Each page has a breadcrumb trail at the top that is based on the URL structure. You should ensure that there is at 
least an `index.md` file within each URL directory, otherwise the links will break.

## Link Checker
Keep the "broken window theory" at bay by ensuring all links work with 
[HTML Proofer](https://github.com/gjtorikian/html-proofer)

Run link checker before committing: 
`rake test`
