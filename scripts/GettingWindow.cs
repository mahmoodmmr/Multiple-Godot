using Godot;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public partial class GettingWindow : Node2D
{
	// Window information structure
	public struct WindowInfo
	{
		public IntPtr Handle;
		public string Title;
		public RECT Rectangle;
	}

	// RECT structure
	[StructLayout(LayoutKind.Sequential)]
	public struct RECT
	{
		public int Left;
		public int Top;
		public int Right;
		public int Bottom;
	}

	// Delegate for the EnumWindows function
	public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

	// P/Invoke declarations
	[DllImport("user32.dll", SetLastError = true)]
	public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

	[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
	public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

	[DllImport("user32.dll")]
	public static extern bool IsWindowVisible(IntPtr hWnd);

	[DllImport("user32.dll")]
	public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

	// List to store window information
	public static List<WindowInfo> windows = new List<WindowInfo>();
	
		// EnumWindows callback function
	public static bool EnumTheWindows(IntPtr hWnd, IntPtr lParam)
	{
		// Only consider visible windows
		if (IsWindowVisible(hWnd))
		{
			// Get window title
			System.Text.StringBuilder title = new System.Text.StringBuilder(256);
			GetWindowText(hWnd, title, title.Capacity);

			// Get window rectangle
			GetWindowRect(hWnd, out RECT rect);

			// Store window information
			windows.Add(new WindowInfo
			{
				Handle = hWnd,
				Title = title.ToString(),
				Rectangle = rect
			});
		}

		// Continue enumeration
		return true;
	}
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
	
	public void CSharpFunc(){
		GD.Print("this is kazem c#");
				EnumWindows(new EnumWindowsProc(EnumTheWindows), IntPtr.Zero);

		// Print window information
		foreach (var window in windows)
		{
			Console.WriteLine($"Title: {window.Title}, Handle: {window.Handle}, Rectangle: {window.Rectangle.Left},{window.Rectangle.Top},{window.Rectangle.Right},{window.Rectangle.Bottom}");
		GD.Print("this is kazem c#");
			GD.Print($"Title: {window.Title}, Handle: {window.Handle}, Rectangle: {window.Rectangle.Left},{window.Rectangle.Top},{window.Rectangle.Right},{window.Rectangle.Bottom}");
		
		}
	}
}
