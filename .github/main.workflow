workflow "Deploy to GitHub Pages" {
  on = "push"
  resolves = ["hugo-deploy-gh-pages"]
}

action "branch-filter" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "snack-og-image" {
  uses = "./.github/actions/snack-og-image"
  args = ""
}

action "hugo-deploy-gh-pages" {
  needs = ["branch-filter", "snack-og-image"]
  uses = "khanhicetea/gh-actions-hugo-deploy-gh-pages@master"
  secrets = [
    "GIT_DEPLOY_KEY",
  ]
  env = {
    HUGO_VERSION = "0.53"
  }
}
