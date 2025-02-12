Python API: https://colab.research.google.com/drive/1FrPvHFJrELTuQkSzOKVSHk62qw1kXEeb?usp=sharing
# Features:
- Process Whatsapp exported chats
- Preprocess text by using latest techniques such as lemmatization
- Use Colab as your goto server  for free
- Learn how to expose endpoints and make api's in python with Ngrok
- (NEW) Use GPT-4o's Tokenizer from Tiktoken to limit input tokens
  
# Initial Setup:
1. Create Accounts in and get api keys from JAMAI and NGROK
2. Create a Project in Jamai and Copy the Project ID e.g. proj_abcdefg12345
3. In google colab go to secrets > add new secrets named "JAMAI", "NGROK" & "PROJ_ID" those should contain your api keys
4. Create a Chat Table in Jamai and name the Table 'chat-bot' OR replace the TABLE_ID below
5. Don't forget to choose engineer the prompt and adjust the output token limit

# Connecting with flutter:
1. After you have done all the steps, run data preprocessing and "exposing colab to flutter" blocks
2. Copy the url by NGROK from routes section and paste it in your app  
___________________________________________
# loveletters

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
