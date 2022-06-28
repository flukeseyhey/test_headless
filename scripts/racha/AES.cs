using Godot;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

public class AES : Control
{
	public const int BlockSize = 16;
	public const int KeyLen = 32;
	public const int IvLen = 16;

	private byte[] key;
	private byte[] iv;
		
	public string Encrypt(string text, string passphrase)
	{
		return Encrypt(Encoding.UTF8.GetBytes(text), passphrase);
	}
	
	public string Encrypt(byte[] data, string passphrase)
	{
		using (var random = new RNGCryptoServiceProvider())
		{
			byte[] salt = new byte[8];
			random.GetBytes(salt);

			DeriveKeyAndIv(passphrase, salt);
			byte[] encrypted;
			using (var aes = new RijndaelManaged())
			{
				aes.BlockSize = BlockSize * 8;
				aes.Mode = CipherMode.CBC;
				aes.Padding = PaddingMode.PKCS7;
				aes.Key = key;
				aes.IV = iv;
				ICryptoTransform encryptor = aes.CreateEncryptor(aes.Key, aes.IV);
				using (var msEncrypt = new MemoryStream())
				{
					using (var csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
					{
						csEncrypt.Write(data, 0, data.Length);
						csEncrypt.FlushFinalBlock();
						encrypted = msEncrypt.ToArray();
					}
				}
			}

			return System.Convert.ToBase64String(Concat(Concat("Salted__", salt), encrypted));
		}
	}
		
	public string Decrypt(string encrypted, string passphrase)
	{
		return Encoding.UTF8.GetString(DecryptToBytes(encrypted, passphrase));
	}

	public byte[] DecryptToBytes(string encrypted, string passphrase)
	{
		byte[] ct = System.Convert.FromBase64String(encrypted);
		if (ct == null || ct.Length <= 0) {
			return new byte[0];
		}

		byte[] salted = new byte[8];
		Array.Copy(ct, 0, salted, 0, 8);
		if (Encoding.UTF8.GetString(salted) != "Salted__") {
			return new byte[0];
		}

		byte[] salt = new byte[8];
		Array.Copy(ct, 8, salt, 0, 8);

		byte[] cipherText = new byte[ct.Length - 16];
		Array.Copy(ct, 16, cipherText, 0, ct.Length - 16);

		DeriveKeyAndIv(passphrase, salt);
		
		byte[] decrypted;
		using (var aes = new RijndaelManaged())
		{
			aes.BlockSize = BlockSize * 8;
			aes.Mode = CipherMode.CBC;
			aes.Padding = PaddingMode.PKCS7;
			aes.Key = key;
			aes.IV = iv;
			ICryptoTransform decryptor = aes.CreateDecryptor(aes.Key, aes.IV);
			using (var msDecrypt = new MemoryStream())
			{
				using (var csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Write))
				{
					csDecrypt.Write(cipherText, 0, cipherText.Length);
					csDecrypt.FlushFinalBlock();
					decrypted = msDecrypt.ToArray();
				}
			}
		}

		return decrypted;
	}
	
	protected void DeriveKeyAndIv(string passphrase, byte[] salt)
	{
		MD5 md5 = MD5.Create();

		key = new byte[KeyLen];
		iv = new byte[IvLen];

		byte[] dx = new byte[] { };
		byte[] salted = new byte[] { };
		byte[] pass = Encoding.UTF8.GetBytes(passphrase);

		for (int i = 0; i < (KeyLen + IvLen / 16); i++) {
			dx = Concat(Concat(dx, pass), salt);
			dx = md5.ComputeHash(dx);
			salted = Concat(salted, dx);
		}

		Array.Copy(salted, 0, key, 0, KeyLen);
		Array.Copy(salted, KeyLen, iv, 0, IvLen);
	}

	private static byte[] Concat(byte[] a, byte[] b)
	{
		byte[] output = new byte[a.Length + b.Length];

		for (int i = 0; i < a.Length; i++)
			output[i] = a[i];
		for (int j = 0; j < b.Length; j++)
			output[a.Length+j] = b[j];

		return output;
	}

	private static byte[] Concat(string a, byte[] b)
	{
		return Concat(Encoding.UTF8.GetBytes(a), b);
	}
		
	public static string TOKENGEN()
	{
		var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
		var stringChars = new char[12];
		var random = new System.Random();

		for (int i = 0; i < stringChars.Length; i++)
		{
			stringChars[i] = chars[random.Next(chars.Length)];
		}

		var finalString = new System.String(stringChars);
		return finalString;
	}
}
