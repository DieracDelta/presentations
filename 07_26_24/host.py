import os
import time
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler

class PDFRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.path = '/main.pdf'
        return super().do_GET()

def serve_pdf():
    server_address = ('0.0.0.0', 6969)
    httpd = HTTPServer(server_address, PDFRequestHandler)
    httpd.serve_forever()

def monitor_pdf_changes(pdf_path, interval=1):
    last_modified = os.path.getmtime(pdf_path)
    while True:
        try:
            current_modified = os.path.getmtime(pdf_path)
            if current_modified != last_modified:
                print("PDF file has been updated. Please reload your browser.")
                last_modified = current_modified
            time.sleep(interval)
        except KeyboardInterrupt:
            break

if __name__ == "__main__":
    pdf_path = './main.pdf'
    print("Serving './main.pdf' on localhost:6969")
    print("Monitoring changes to './main.pdf'")

    # Start server in a new thread
    server_thread = threading.Thread(target=serve_pdf)
    server_thread.daemon = True
    server_thread.start()

    # Monitor PDF changes in the main thread
    monitor_pdf_changes(pdf_path)

