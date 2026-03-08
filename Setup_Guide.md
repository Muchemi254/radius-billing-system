# Complete Setup Guide: PHPNuxBill RADIUS & MikroTik Hotspot
**Architecture Option 2: RADIUS Server Authentication with Walled Garden & Free Trial**

This document provides a comprehensive, step-by-step guide to setting up a Hotspot billing system from scratch. This guide assumes you are starting with a **factory-reset MikroTik router** and a **fresh PHPNuxBill Docker installation**.

---

## Part 1: Server & RADIUS Setup (PHPNuxBill)

Your billing system (PHPNuxBill) and FreeRADIUS server are running via Docker. They need to be configured to accept connections from your MikroTik router.

### 1. Configure the RADIUS Client (FreeRADIUS)
By default, FreeRADIUS only accepts requests from specific IP ranges. You must allow your MikroTik's IP address.

1. In your project directory, open the file `raddb/config_data/clients.conf`.
2. Scroll to the bottom and locate the `client mikrotik` block.
3. Update the `ipaddr` to match your MikroTik router's IP address (the IP that will reach the server).

```text
client mikrotik {
    ipaddr = 192.168.1.0/24  # Change this to your MikroTik's IP or Subnet
    secret = testing123      # This is your RADIUS secret key
}
```
4. Restart the FreeRADIUS container to apply changes:
   `docker-compose restart freeradius`

### 2. Enable RADIUS in PHPNuxBill
1. Log into your PHPNuxBill Admin Dashboard.
2. Navigate to **Settings** → **General Settings** → **FreeRADIUS**.
3. Toggle **Radius** to **ON** and save the changes.
4. Go to the **RADIUS** menu on the sidebar, then click **RADIUS NAS**.
5. Click **Add** to register your router:
   * **IP Address:** Your MikroTik's IP address.
   * **Secret:** `testing123` (Must match the secret in `clients.conf`).
   * **Type:** Select `Mikrotik`.

---

## Part 2: MikroTik Router Basic Setup (From Scratch)

This phase connects your MikroTik to the internet and prepares the local network (LAN) for your Hotspot users.

*(You can run these commands in the MikroTik Terminal via WinBox or WebFig. We assume **ether1** is your Internet/WAN port, and **ether2** is your Hotspot/LAN port).*

### 1. Internet Access (WAN)
Get internet from your ISP on `ether1`.
```routeros
/ip dhcp-client add interface=ether1 disabled=no
```
*(If your ISP requires PPPoE or Static IP, configure that on ether1 instead).*

### 2. Enable NAT (Internet Sharing)
Allow devices connected to your router to share the internet connection.
```routeros
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
```

### 3. Setup the Hotspot Port (LAN)
Assign an IP address to `ether2` for your Hotspot network.
```routeros
/ip address add address=10.0.0.1/24 interface=ether2 network=10.0.0.0
```

### 4. Create the IP Pool & DHCP Server
Create the pool of IP addresses for your users and set up the DHCP server to assign them.
```routeros
/ip pool add name=hotspot_pool ranges=10.0.0.10-10.0.0.254
/ip dhcp-server add name=hotspot_dhcp interface=ether2 address-pool=hotspot_pool disabled=no
/ip dhcp-server network add address=10.0.0.0/24 gateway=10.0.0.1 dns-server=8.8.8.8,1.1.1.1
```

---

## Part 3: Build the MikroTik Hotspot

Now we build the Captive Portal system on `ether2`.

### 1. Create Profiles
Create a default user profile and the main server profile (`hsprof1`).
```routeros
/ip hotspot user profile add name=default shared-users=1
/ip hotspot profile add name=hsprof1 hotspot-address=10.0.0.1 dns-name=hotspot.local login-by=mac,cookie,http-chap
```

### 2. Create the Hotspot Server
Attach the Hotspot system to `ether2`.
```routeros
/ip hotspot add name=hotspot1 interface=ether2 profile=hsprof1 address-pool=hotspot_pool disabled=no
```

---

## Part 4: Link MikroTik to PHPNuxBill (RADIUS)

We now instruct the Hotspot to authenticate users against your PHPNuxBill server instead of the router's local database.

### 1. Add the RADIUS Server to MikroTik
Replace `192.168.1.100` with the actual IP address of your PHPNuxBill server.
```routeros
/radius add address=192.168.1.100 secret=testing123 service=hotspot timeout=3s
```
*(**Crucial:** `timeout=3s` increases the wait time for a response. Without this, logins may fail randomly due to slight network latency).*

### 2. Force Hotspot to use RADIUS
Update the `hsprof1` profile to use RADIUS and send accounting data (MBs/Time usage) every 5 minutes.
```routeros
/ip hotspot profile set [find name="hsprof1"] use-radius=yes radius-interim-update=00:05:00
```

---

## Part 5: Walled Garden & Payment Gateway Setup

When a new user connects, they are blocked from the internet. The Walled Garden allows them to reach your billing portal to register and pay without needing an active plan.

### 1. Allow Access to PHPNuxBill
Replace `192.168.1.100` with your PHPNuxBill server's IP.
```routeros
/ip hotspot walled-garden ip add dst-address=192.168.1.100 action=accept
```

### 2. Allow Payment Gateways
If you use online payment gateways (e.g., Stripe, PayPal, Paystack), users need to reach their servers to complete checkout. Add the necessary domains:
```routeros
/ip hotspot walled-garden add dst-host=*stripe.com
/ip hotspot walled-garden add dst-host=*paypal.com
```
*(Add any other domains required by your specific payment provider).*

---

## Part 6: Setting up the 1-Hour "Free Trial" (Wall Green)

This allows users to click a button on the captive portal to get 1 hour of free internet before being required to register or pay.

### 1. Enable Trial on the Hotspot Profile
Run this command to enable the trial feature, set the limit to 1 hour, and link it to the default user profile.
```routeros
/ip hotspot profile set [find name="hsprof1"] 
    login-by=mac,cookie,http-chap,trial 
    trial-uptime-limit=1h 
    trial-user-profile=default
```

### 2. Customize the MikroTik Login Page
You need to provide buttons on your Captive Portal page so users can choose between the Free Trial or Buying a Plan.

1. Open the MikroTik **Files** menu in WinBox.
2. Find and drag the file `hotspot/login.html` to your computer.
3. Open it in a text editor (like Notepad).
4. Add the following HTML links inside the `<body>` tag:

```html
<!-- Link to trigger the 1-hour Free Trial natively -->
<a href="$(link-login-only)?dst=$(link-orig-esc)&amp;username=T-$(mac-esc)" style="display:block; padding:10px; background:green; color:white; text-align:center; margin-bottom:10px; text-decoration:none; border-radius:5px;">
   Click here for 1 Hour Free Trial
</a>

<!-- Link to your PHPNuxBill Server for Registration/Purchase -->
<!-- Replace 192.168.1.100 with your server IP -->
<a href="http://192.168.1.100/index.php?_route=register" style="display:block; padding:10px; background:blue; color:white; text-align:center; text-decoration:none; border-radius:5px;">
   Register & Buy a Plan
</a>
```
5. Save the file and drag it back into the `hotspot/` folder in WinBox to replace the old one.

---

## Final User Workflow

1. **Connection:** An unregistered user joins your Wi-Fi network (`ether2`). The Captive Portal appears.
2. **Options:** 
   - They click the **"1 Hour Free Trial"** button. MikroTik grants them exactly 1 hour of internet (locally managed).
   - *OR* they click the **"Register & Buy a Plan"** button.
3. **Registration:** Because of the Walled Garden rule, they are safely routed to the PHPNuxBill portal without having active internet. They create an account and pay for a Plan via the configured Payment Gateway.
4. **Authentication:** Once paid, the user returns to the captive portal and enters their new username/password.
5. **RADIUS Check:** MikroTik asks the FreeRADIUS container if the user is valid. FreeRADIUS checks the MySQL database, confirms the payment is active, and tells MikroTik to grant full internet access according to the purchased plan's speed limits.
