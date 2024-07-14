+++
title = "Diving into Nix ecosystem - My Journey part 1"
description = "How I dived into the nix ecosystem. My journey starting from learning nix basics to completely switching to NixOS"
date = "2024-07-14"
tags = ["nix", "linux", "articles"]
author = "Jayadeep KM"
toc = true
series = ["Nix"]
projects = ["Nix"]
+++

Nix a concept that is known for it's steap learning curve. It is hard to understand, harder to explain and nearly impossible to master even for the nerdiest Linux enthusiasts. In this post, I would like to share my Journey of embracing Nix from a long time Arch linux user. Hopefully I can inspire a few people to get curious about nix and even start using it. This is part-1 of the series where I will mostly cover the beginning of my journey and a bit of backstory. In the coming posts, I will go a bit in-depth on the technical side.

# Where I come from

I was using Arch linux as my daily driver for nearly 5 years. It was surprisingly stable and easy to use. The Ubuntu system I used before had more issues than the so called "unstable" Arch linux. I was using I3 window manager and Vim as my editor of choice. I used to update packages quite frequently. Arch linux is usually the first to receive package updates. AUR had almost any package I was looking for. Arch wiki is great and any kind of issues were easy to fix with a bit of googling, thanks to a huge community of users.

However, there were a few quirks which annoyed me a little. I had to reinstall the OS a few times, due to broken Hard disk, migrating to a different laptop etc. Every time I had to reinstall, it took me over a day to install and setup. Still I end up with a slighty different configuration than i had before. Each time I fix an issue (for example, getting bluetooth to work), I end up forgetting how it was done and next time I had to research and figure it out again. I ended up documenting the list of packages I install, fixing common issues etc. But it became quite messy over time.

# Declarative Programming

I was quite facsinated by the idea of declarative programming. From [Wikipedia](https://en.wikipedia.org/wiki/Declarative_programming)

> Declarative programming is a non-imperative style of programming in which programs describe their desired results without explicitly listing commands or steps that must be performed

I was working heavily on Terraform at that moment. So the idea of declaratively configuring an entire OS sounded really interesting to me. To explain what a game changing concept this is, here is a simple example of the difference between these two:

Imagine, you want to create a user in your system. In imperative style, it would be:

1. Create new user - `jayadeep`
1. Assign group for the user - `net-admins`
1. Create home directory - `/home/jayadeep`
1. Assign home directory permissions

You just instruct the system to do these in order. The System blindly accepts the instructions and executes it.
In declarative style, it would be:

Make sure following user exists with the given configuration:

```
name: jayadeep
groups: [net-admins]
homeDir: '/home/jayadeep'
```
Then the corresponding program will run the logic to ensure that the system has the users created with the given attributes. [Here](https://dev.to/khophi/explain-declarative-vs-imperative-programming-like-i-m-5-2a1l) is a more detailed explanination of the difference between these two.

In short, declarative syntax makes our life easier by hiding the implementation details.

# Hearing about Nix, and getting started

Nix is a package manager, a build system, an OS (NixOS) and much more. Before getting to the complexity of nix ecosytem, let me explain where I started. At first I heard about how nix can configure an entire OS declaratively. So I downloaded a NixOs ISO, booted into a VM and started tinkering with the configuration.

Here is a sample configuration of NixOS

```nix
{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialPassword = "test";
  };

  environment.systemPackages = with pkgs; [
    cowsay
    lolcat
  ];

  system.stateVersion = "23.11";
}
```

Although the syntex is a bit weird (looks like a JSON, but it isn't), the configuration is easy to read and understand. What it does is the following,

- Enable systemd bootloader (alternative to grub)
- Add a user named `alice`, with initial password `test`
- Install `cowsay` and `lolcat` packages

With a bit of googling, and come up with a basic configuration that I can install and boot with. I still didn't have much clue about the inner workings of Nix though. Once the configuration is ready, I just had to run the following command and it immedietly applies the changes

```
nix-rebuild --switch
```

# First working configuration

Here is my first commit on Git: [Nixdots](https://github.com/kmjayadeep/nixdots/commit/cc68e219574a9a91cbc18fb2878a0be3840036fd)

This was my first working configuration after days of tinkering with config, restructuring, following various tutorials etc.

One clear advantage NixOs has compared to other OSes is that, the nix package ecosystem is really huge. It has over 80k+ packages available the repositories, which is much more than AUR or any other package managers out there. So I was confident that I would be able to configure the sysystem to be able to completely switch from Arch linux.

# My first impressions

Declaring the list of packages like [this](https://github.com/kmjayadeep/nixdots/blob/4c732a4671903804f4dede9a0a40ffd6d4d16771/modules/packages.nix) was life changing for me. It allowed me to discard the messy notes. At every point of time, I know what packages are installed in the system by looking at this file. This made it really easy to reproduce the system in case of a reinstall.

Similarly, see how [easy](https://github.com/kmjayadeep/nixdots/blob/4c732a4671903804f4dede9a0a40ffd6d4d16771/modules/system.nix#L89) it is to enable bluetooth in Nixos

```nix
hardware = {
  bluetooth = {
    enable = true;
    settings = {
      General = {
        # Show battery percentage of bt headset
        Experimental = true;
      };
    };
  };
};
```

This small snippet did all the magic. Since NixOS forces us to manage everything declaritively, once we fix an issue and persist in code, it is fixed forever! Every package and every confguration is versioned and hashed. Nix goes to great lengths to ensure that the configuration is highly reproducible, byte by byte, no matter where or when we apply the configuration.

# Summary and upcoming posts

You can find my current NixOS config in https://github.com/kmjayadeep/nixdots
In the upcoming posts, I will explain more about Nix package manager, Flakes, Devshells and more.
