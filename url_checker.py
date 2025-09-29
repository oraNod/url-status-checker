#!/usr/bin/python3
"""
URL Status Checker - A tool to verify HTTP status codes and redirects for URLs.
"""

import argparse
import csv
import glob
import os
import sys
from datetime import datetime
from typing import Dict, List, Tuple
from urllib.parse import urljoin

import requests

HOST: str = "https://ansible.readthedocs.io/"
REQUEST_TIMEOUT: int = 30  # seconds


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "-d", "--directory", help="Directory that contains txt files with URL paths"
    )
    group.add_argument("-f", "--file", help="Single file that contains URL paths")
    group.add_argument("-u", "--url", help="Single URL path to verify")
    return parser.parse_args()


def get_txt_files(directory: str) -> List[str]:
    if not os.path.isdir(directory):
        print(f"Error: Directory {directory} not found")
        sys.exit(1)

    txt_files = glob.glob(os.path.join(directory, "*.txt"))
    if not txt_files:
        print(f"Error: No .txt files found in {directory}")
        sys.exit(1)

    return sorted(txt_files)


def get_output_filenames(input_file: str) -> Tuple[str, str]:
    base_name = os.path.splitext(os.path.basename(input_file))[0]
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base_output = f"url_report_{base_name}_{timestamp}"
    return f"{base_output}.txt", f"{base_output}.csv"


def load_urls_from_file(file_path: str) -> List[str]:
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        return []
    except IOError as e:
        print(f"Error reading {file_path}: {str(e)}")
        return []


def check_url(url: str) -> Tuple[str, str]:
    try:
        response: requests.Response = requests.head(
            url, allow_redirects=False, timeout=REQUEST_TIMEOUT
        )
        status: int = response.status_code
        redirect_url: str = (
            response.headers.get("Location", "") if status in [301, 302] else ""
        )
        if redirect_url and not redirect_url.startswith(("http://", "https://")):
            redirect_url = urljoin(url, redirect_url)
        return str(status), redirect_url
    except requests.RequestException as e:
        return str(e), ""


def process_urls(urls: List[str]) -> List[Dict[str, str]]:
    results = []
    for page in urls:
        url = urljoin(HOST, page)
        status, redirect = check_url(url)

        result = {
            "original_path": page,
            "full_url": url,
            "status": status,
            "redirect_url": redirect,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        }
        results.append(result)
    return results


def write_text_report(results: List[Dict[str, str]], output_file: str) -> None:
    try:
        with open(output_file, "w", encoding="utf-8") as f:
            for result in results:
                f.write(f"Original Path: {result['original_path']}\n")
                f.write(f"Full URL: {result['full_url']}\n")
                f.write(f"Status: {result['status']}\n")
                if result["redirect_url"]:
                    f.write(f"Redirects to: {result['redirect_url']}\n")
                f.write(f"Timestamp: {result['timestamp']}\n")
                f.write("\n")
        print(f"Text report generated: {output_file}")
    except IOError as e:
        print(f"Error writing to {output_file}: {str(e)}")


def write_csv_report(results: List[Dict[str, str]], output_file: str) -> None:
    fieldnames = ["original_path", "full_url", "status", "redirect_url", "timestamp"]
    try:
        with open(output_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(results)
        print(f"CSV report generated: {output_file}")
    except IOError as e:
        print(f"Error writing to {output_file}: {str(e)}")


def handle_single_url(url: str) -> None:
    results = process_urls([url])
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    txt_file = f"url_report_single_{timestamp}.txt"
    csv_file = f"url_report_single_{timestamp}.csv"

    write_text_report(results, txt_file)
    write_csv_report(results, csv_file)


def handle_single_file(file_path: str) -> None:
    urls = load_urls_from_file(file_path)
    if urls:
        results = process_urls(urls)
        txt_file, csv_file = get_output_filenames(file_path)
        write_text_report(results, txt_file)
        write_csv_report(results, csv_file)


def handle_directory(directory: str) -> None:
    txt_files = get_txt_files(directory)
    print(f"Found {len(txt_files)} txt files in {directory}")

    for file_path in txt_files:
        print(f"\nProcessing {file_path}...")
        urls = load_urls_from_file(file_path)
        if urls:
            results = process_urls(urls)
            txt_file, csv_file = get_output_filenames(file_path)
            write_text_report(results, txt_file)
            write_csv_report(results, csv_file)


def main() -> None:
    args = parse_arguments()

    if args.url:
        handle_single_url(args.url)
    elif args.file:
        handle_single_file(args.file)
    else:
        handle_directory(args.directory)


if __name__ == "__main__":
    main()
