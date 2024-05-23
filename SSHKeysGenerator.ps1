# Step 1: Generate new SSH key pair
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N ""

# Step 2: Start the SSH agent
Start-Service ssh-agent

# Step 3: Add SSH key to the SSH agent
ssh-add "$env:USERPROFILE\.ssh\id_rsa"

# Step 4: Stop the SSH agent
Stop-Service ssh-agent

# Step 5: Copy Your Public Key To Your Clipboard
notepad "$env:USERPROFILE\.ssh\id_rsa.pub"
