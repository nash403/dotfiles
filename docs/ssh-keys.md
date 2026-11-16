# SSH keys

What the install wizard does for you, step by step, to redo it by hand or for a second key.

## Create a key

```bash
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519
```

Pick a passphrase: with the macOS keychain you only type it once. Without one, the private key sits unencrypted on disk, and anyone who copies `~/.ssh` can push as you.

## Keep the passphrase in the keychain

Add this at the end of `~/.ssh/config` (create it if needed, then `chmod 600 ~/.ssh/config`):

```
Host *
  IgnoreUnknown UseKeychain
  UseKeychain yes
  AddKeysToAgent yes
```

Then load the key once:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

`UseKeychain` only exists in Apple's `ssh`; `IgnoreUnknown` keeps other `ssh` builds from failing on it.

## Add it to GitHub or GitLab

Copy the public key:

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

- **GitHub**: [Settings → SSH and GPG keys → New SSH key](https://github.com/settings/ssh/new). Add it as an **Authentication Key**. To sign commits, add it a second time as a **Signing Key**.
- **GitLab**: Preferences → SSH Keys (`https://<your-gitlab>/-/user_settings/ssh_keys`) → Add new key. Usage: **Authentication & Signing**.

Check it works:

```bash
ssh -T git@github.com
```

```bash
ssh -T git@gitlab.com
```

## Sign commits with the key

```bash
git config --file ~/.gitconfig gpg.format ssh
git config --file ~/.gitconfig user.signingkey ~/.ssh/id_ed25519.pub
git config --file ~/.gitconfig commit.gpgsign true
git config --file ~/.gitconfig tag.gpgsign true
```

So that git can verify signatures locally, list your key as an allowed signer:

```bash
echo "you@example.com $(cat ~/.ssh/id_ed25519.pub)" >> ~/.ssh/allowed_signers
git config --file ~/.gitconfig gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

Check: `git log --show-signature -1` shows `Good "git" signature`.

Always pass `--file ~/.gitconfig`: without it, git may write to `~/.config/git/config`, which is a file of this repo.

## Two accounts on the same platform

Typical case: a personal GitLab account and a work one, each with its own key.

1. One key per account: `id_ed25519` (personal) and `id_ed25519_work` (work), both added to their account.
2. Recommended: switch by folder with `includeIf`. Every repo cloned under your work folder (the one you gave the wizard, see `WORK_DIR` in `custom/dotfiles.env`) then uses the work identity, without touching the clone URLs.

   In `~/.gitconfig`, with your work folder in place of `<WORK_DIR>` (keep the trailing `/`):

   ```
   [includeIf "gitdir:<WORK_DIR>/"]
     path = ~/.gitconfig-work
   ```

   In `~/.gitconfig-work`:

   ```
   [user]
     email = you@company.example
     signingkey = ~/.ssh/id_ed25519_work.pub
   [core]
     sshCommand = ssh -i ~/.ssh/id_ed25519_work -o IdentitiesOnly=yes
   ```

3. Alternative: a host alias in `~/.ssh/config`. It works outside the work folder, but every clone URL must use the alias.

   ```
   Host gitlab-work
     HostName gitlab.com
     IdentityFile ~/.ssh/id_ed25519_work
     IdentitiesOnly yes
   ```

   ```bash
   git clone git@gitlab-work:company/project.git
   ```

Check, inside a work repo: `git config core.sshCommand` prints the work key, and `git config user.email` the work email.
