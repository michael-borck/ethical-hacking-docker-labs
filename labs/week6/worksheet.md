# Week 6: Introduction to Password Security
## CYB204 Ethical Hacking - Beginner Lab

---

## **Before We Start (5 minutes)**

### **Important Rules**
✅ **DO:** Only test passwords in this lab environment  
✅ **DO:** Ask for help if you get stuck  
✅ **DO:** Work with a partner if you want  
❌ **DON'T:** Test passwords on any real websites  
❌ **DON'T:** Share any passwords you crack outside class  

### **Quick Setup**
```bash
# Step 1: Get the lab files
git clone https://github.com/michael-borck/password-lab.git
cd password-lab

# Step 2: Run the setup script
chmod +x setup.sh
./setup.sh

# Step 3: Start the lab environment
docker-compose up -d

# Step 4: Enter the container
docker exec -it password-cracking-lab sh

# Step 5: Check you're in the right place
pwd
# Should show: /
```

**Check:** Can you see the command prompt? ✓ Yes ✓ No

---

## **Part 1: Understanding Passwords (20 minutes)**

### **Exercise 1.1: What is a Hash?**
A hash is like a fingerprint for a password. Let's create some!

```bash
# Type this command to hash the word "hello"
echo -n "hello" | md5sum
```

**Write what you see:** _________________________________

Now try with your first name:
```bash
echo -n "yourname" | md5sum
```

**Write your result:** _________________________________

**Question:** Can you turn the hash back into your name? (Circle one)
- YES - I can reverse it
- NO - It's one-way only

### **Exercise 1.2: Different Hash Types**
Let's see how different hash types look:

```bash
# Same password, different hash types
echo -n "password" | md5sum    # 32 characters
echo -n "password" | sha1sum   # 40 characters
echo -n "password" | sha256sum # 64 characters
```

**Fill in the table:**
| Hash Type | Length | First 6 characters |
|-----------|--------|-------------------|
| MD5       | 32     |                   |
| SHA-1     | 40     |                   |
| SHA-256   | 64     |                   |

### **Exercise 1.3: Why Do We Hash Passwords?**
Circle the best answer:
- A) To make them look cool
- B) So even if someone steals them, they can't read them
- C) To make login faster
- D) Because it's required by law

---

## **Part 2: Your First Password Crack (25 minutes)**

### **Exercise 2.1: Cracking with John the Ripper**

Let's crack our first password! We'll start with something easy.

```bash
# Create a file with a hash to crack
echo "5d41402abc4b2a76b9719d911017c592" > myfirst.txt

# Try to crack it
john myfirst.txt

# See what password it found
john --show myfirst.txt
```

**What password did John find?** _________________

**How long did it take?** _________________

### **Exercise 2.2: Using a Wordlist**

Sometimes we need to give John hints. A wordlist is like a dictionary of common passwords.

```bash
# Look at our wordlist
head /wordlists/basic.txt

# Create a new hash to crack
echo "5f4dcc3b5aa765d61d8327deb882cf99" > test2.txt

# Use the wordlist
john --wordlist=/wordlists/basic.txt test2.txt

# Check the result
john --show test2.txt
```

**What password was it?** _________________

**Was it in the wordlist?** ✓ Yes ✓ No

### **Exercise 2.3: Making Your Own Hash**

Now let's create and crack your own password:

```bash
# Pick a simple word (like: cat, dog, sun)
# Create its hash
echo -n "yourword" | md5sum

# Copy the hash (without the dash at the end)
# Put it in a file
echo "paste_your_hash_here" > myhash.txt

# Try to crack it
john --wordlist=/wordlists/basic.txt myhash.txt
```

**Did John crack your password?** ✓ Yes ✓ No

If no, why not? _________________________________

---

## **Part 3: Network Password Attacks (20 minutes)**

### **Exercise 3.1: Finding Our Target**

We have a practice server to attack (legally!).

```bash
# Find the target server's IP address
getent hosts ssh-target
```

**Write the IP address:** _________________

### **Exercise 3.2: Using Hydra (Simplified)**

Hydra tries to guess passwords for online services.

```bash
# This will try 3 passwords for the admin user
echo "password" > minilist.txt
echo "123456" >> minilist.txt
echo "letmein" >> minilist.txt

# Run Hydra (this might take 30 seconds)
hydra -l admin -P minilist.txt ssh://ssh-target
```

**Did Hydra find the password?** ✓ Yes ✓ No

**If yes, what was it?** _________________

### **Exercise 3.3: Understanding the Danger**

**Discussion Questions:**
1. If Hydra can guess 100 passwords per second, how many could it try in one day?
   
   Math: 100 × 60 seconds × 60 minutes × 24 hours = _________________

2. How could a website stop Hydra attacks? (Write one idea)
   
   _________________________________

---

## **Part 4: Creating Strong Passwords (15 minutes)**

### **Exercise 4.1: Testing Password Strength**

Let's test different passwords to see which are strong:

```bash
# Test these passwords
python3 -c "
passwords = ['123456', 'password', 'MyDog123', 'MyDogIsMax2024!']
for p in passwords:
    print(f'{p:20} Strength: ', end='')
    if len(p) < 8:
        print('WEAK - Too short')
    elif p.lower() in ['password', '123456', 'qwerty']:
        print('WEAK - Too common')
    elif not any(c.isdigit() for c in p):
        print('MEDIUM - Add numbers')
    else:
        print('STRONG - Good job!')
"
```

### **Exercise 4.2: Make a Strong Password**

Create a strong password using this formula:
1. Pick 3 random words
2. Add a number
3. Add a symbol

**Example:** `Coffee@Plant7Desk!`

**Your strong password idea:** _________________________________

### **Exercise 4.3: Password Rules**

**Check the good password rules:**
- [ ] At least 12 characters long
- [ ] Different for every website
- [ ] Changed every month
- [ ] Includes your birthday
- [ ] Uses a password manager
- [ ] Written on a sticky note
- [ ] Has numbers and symbols
- [ ] Is your pet's name

---

## **Part 5: Professional Ethics (10 minutes)**

### **Exercise 5.1: Legal or Illegal?**

Mark each scenario as LEGAL or ILLEGAL:

| Scenario | Legal? |
|----------|--------|
| Testing passwords on your own computer | |
| Trying to crack your friend's Facebook | |
| Testing a company's security with written permission | |
| Cracking passwords for a class assignment | |
| Selling cracked passwords online | |
| Testing your school's WiFi without permission | |

### **Exercise 5.2: What Would You Do?**

**Scenario:** While practicing, you accidentally discover your teacher's password is "password123".

What should you do? (Circle one)
- A) Tell everyone in class
- B) Use it to change your grades
- C) Privately tell the teacher they should change it
- D) Post about it on social media

**Why?** _________________________________

---

## **Quick Quiz (5 minutes)**

1. **What is a hash?**
   - A) A type of food
   - B) A one-way transformation of a password
   - C) A social media tag
   - D) A programming language

2. **Which password is strongest?**
   - A) password
   - B) 12345678
   - C) MyNameIsJohn
   - D) Tr0ub4dor&3

3. **What tool cracks offline passwords?**
   - A) Hydra
   - B) John the Ripper
   - C) Nmap
   - D) Wireshark

4. **True/False: You need permission to test passwords on any system you don't own.**
   - True / False

5. **How long should a strong password be?**
   - A) 4 characters
   - B) 6 characters
   - C) 8 characters
   - D) 12+ characters

---

## **Cleanup**

```bash
# Exit the container
exit

# Stop the lab
docker-compose down
```

---

## **Homework (Optional)**

1. **Research:** Look up the "RockYou password breach". Write 3 things you learned:
   - _________________________________
   - _________________________________
   - _________________________________

2. **Practice:** Try the "Crack the Hash" room on TryHackMe (free tier)

3. **Think:** Design a password policy for a small business. What 3 rules would you include?
   - _________________________________
   - _________________________________
   - _________________________________

---

## **Summary**

Today you learned:
✓ What password hashes are  
✓ How to crack weak passwords  
✓ Why strong passwords matter  
✓ The importance of permission  
✓ How to create strong passwords  

**Remember:** These skills are for protecting systems, not attacking them!

---

## **Need Help?**

- Can't get a command to work? Check for typos!
- Getting errors? Ask your instructor or partner
- Confused about a concept? That's normal - ask questions!
- Lab not working? Try: `docker-compose restart`

**Instructor Contact:** _________________________________