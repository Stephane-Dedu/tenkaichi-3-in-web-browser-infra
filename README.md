# Tenkaichi 3 in a web browser: infrastructure

Terraform for the small server behind
[tenkaichi-3-in-web-browser](https://github.com/Stephane-Dedu/tenkaichi-3-in-web-browser). It's a quick
side project for playing with friends, so this is kept minimal.

## What the server does (and doesn't)

The game runs in each player's browser (WebAssembly + WebGL 2), from that player's own disc image. The
image never leaves their PC. The server never sees game data and does no emulation. It only:

- serves the page and runtime as static files behind a shared password. Caddy sends them precompressed
  (Brotli), so the ~120 MB WebAssembly module goes out as ~8 MB;
- relays the players' inputs (a few hundred bytes per frame) through a small Node lobby over WebSocket,
  plus UDP for the PC version;
- holds one shared starting save in a public bucket. Terraform state goes in a separate private bucket.

The VM's software (Caddy, the relay) is installed by the application's deploy script, not by Terraform.

## Why this server

- **e2-micro** (2 shared vCPUs, 1 GB). Static files and input relaying keep the CPU near idle, and 1 GB
  is plenty for Caddy and Node. Game performance depends on each player's PC and browser (Chrome or
  Edge), not on the server. A bigger machine would cost more and play the same.
- **A region close to the players** (`europe-west9`, Paris, by default). Netplay is lockstep: each frame
  waits for the partner's input, and every input travels to the relay and back. Round-trip time is the
  one server property players feel. The free-tier e2-micro exists only in a few US regions; from Europe
  that adds ~100 ms per round trip, so a nearby paid VM is worth a few dollars. Pick the region nearest
  your group.
- **Premium network tier.** Traffic joins Google's network at the edge nearest each player, which gives
  steadier latency than the Standard tier.
- **10 GB standard disk.** It holds the OS and a ~150 MB site that stays in memory once read. Disk speed
  doesn't matter here.
- **Static IP**, so the site's address and DNS record survive a stop/start.

Cost is about $11 a month while running. A stopped VM still pays for its disk and its reserved IP.

## Layout

- `project/`, `network/`, `compute/`, `dns/`: the existing project, firewall rules, static IP, VM and
  Route 53 record (CNAME to the VM's `sslip.io` name). They were adopted with `imports.tf`, so the import
  changes nothing.
- `storage/`: a separate stack for the public base-save bucket and the private state bucket. It created
  the state bucket, so it keeps its own state (prefix `storage`).

## Use

Real values live only in gitignored local files: `terraform.tfvars`, `backend.hcl`,
`compute/ssh-keys.txt`, state, plans and saves. Each has an `.example` next to it.

```sh
cp terraform.tfvars.example terraform.tfvars            # project, billing, owner, DNS zone
cp backend.hcl.example backend.hcl                      # your state bucket
cp compute/ssh-keys.txt.example compute/ssh-keys.txt    # the VM's current ssh-keys metadata
terraform init -backend-config=backend.hcl
terraform plan
```

`storage/` works the same way, from its own directory. For a new project, apply `storage/` once without a
backend to create the buckets. Then add `backend.hcl` and run
`terraform init -backend-config=backend.hcl -migrate-state`.

Authentication uses the usual credential chains: gcloud Application Default Credentials, and the AWS CLI
profile for Route 53. No credentials go in these files.

The base-save bucket is public on purpose, because every player starts from the same save. It holds the
save and its manifest only, and browsers never get write access. The state bucket enforces public access
prevention.
