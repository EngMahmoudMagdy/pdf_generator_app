# HTML to PDF Conversion Checklist

This checklist ensures that all important HTML tags are considered when converting to PDF. ✅ indicates commonly supported tags, while ⚠️ indicates tags that may have limited support.

## **Basic Tags**
- [x] `<html>` ✅
- [x] `<head>` ✅
- [x] `<title>` ✅
- [x] `<meta>` ✅
- [x] `<body>` ✅

## **Text Formatting**
- [x] `<h1> to <h6>` ✅
- [x] `<p>` ✅
- [x] `<strong>` (Bold) ✅
- [x] `<em>` (Italic) ✅
- [x] `<u>` (Underline) ✅
- [x] `<small>` ✅
- [x] `<mark>` (Highlighted text) ⚠️
- [x] `<del>` (Strikethrough) ✅
- [x] `<sup>` (Superscript) ✅
- [x] `<sub>` (Subscript) ✅
- [x] `<code>` ✅
- [x] `<pre>` (Preformatted text) ✅

## **Lists**
- [x] `<ul>` (Unordered list) ✅
- [x] `<ol>` (Ordered list) ✅
- [x] `<li>` (List item) ✅
- [x] `<dl>` (Description list) ⚠️
- [x] `<dt>` (Description term) ⚠️
- [x] `<dd>` (Description detail) ⚠️

## **Tables**
- [x] `<table>` ✅
- [x] `<tr>` ✅
- [x] `<th>` (Table header) ✅
- [x] `<td>` (Table data) ✅
- [x] `<caption>` (Table caption) ⚠️
- [x] `<colgroup>` and `<col>` (Column styling) ⚠️

## **Forms & Inputs**
- [x] `<form>` ⚠️
- [x] `<input>` (Text fields, checkboxes, radio buttons) ⚠️
- [x] `<select>` (Dropdown) ⚠️
- [x] `<option>` ⚠️
- [x] `<textarea>` ⚠️
- [x] `<button>` ⚠️
- [x] `<label>` ✅

## **Media & Embeds**
- [x] `<img>` (Images) ✅
- [x] `<video>` ⚠️ (Often unsupported in PDFs)
- [x] `<audio>` ⚠️ (Not supported in PDFs)
- [x] `<iframe>` ⚠️ (Limited support)
- [x] `<embed>` ⚠️ (Limited support)
- [x] `<object>` ⚠️ (Limited support)

## **Links & Navigation**
- [x] `<a>` (Hyperlinks) ✅
- [x] `<nav>` ⚠️
- [x] `<header>` ✅
- [x] `<footer>` ✅

## **CSS & Styling**
- [x] Inline styles (`style="color: red;"`) ✅
- [x] Internal `<style>` ⚠️ (Limited support)
- [x] External stylesheets (`<link rel="stylesheet">`) ❌ (Not supported in most PDF tools)

## **Other Elements**
- [x] `<blockquote>` ✅
- [x] `<hr>` (Horizontal rule) ✅
- [x] `<br>` (Line break) ✅
- [x] `<div>` ✅
- [x] `<span>` ✅
- [x] `<section>` ✅
- [x] `<article>` ✅

## **JavaScript & Dynamic Content**
- [ ] `<script>` ❌ (Not executed in PDFs)
- [ ] `<noscript>` ❌ (No effect in PDFs)

## **Notes**
- Some PDF tools may ignore **CSS styling**, so use inline styles whenever possible.
- **Forms and interactive elements** (buttons, dropdowns) are often not supported in PDFs.
- To ensure the best output, **use a web-based renderer** like `wkhtmltopdf` or `Puppeteer`.

---

✅ **Use this checklist to verify which HTML tags are well-supported when converting HTML to PDF in Flutter or any other tool.**
