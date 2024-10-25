from flask import *
import os
import subprocess

app = Flask(__name__)

@app.route('/admin')
def hello_admin():
   return 'Hello Admin'

@app.route('/guest/<guest>')
def hello_guest(guest):
   return 'Hello %s as Guest' % guest

@app.route('/user/<name>')
def hello_user(name):
   if name =='admin':
      return redirect(url_for('hello_admin'))
   else:
      return redirect(url_for('hello_guest',guest = name))


@app.route('/systemctl')
def run_another_function():
    command = 'bash -c "source functions.sh && servicectl_check"'
    try:
        result = subprocess.check_output(command, shell=True, text=True)
        output = result
    except subprocess.CalledProcessError as e:
        output = f"Error: {e.output}"  # Capture error output if command fails

    return f'<pre>{output}</pre>'
 
@app.route('/test', methods=['GET'])
def test():
   os.system('./functions.sh > output.txt')
   with open('output.txt', 'r') as file:  # Change 'your_file.txt' to your file's name
      content = file.read()
   return Response(content, mimetype='text/plain')   

# @app.route('/function/<string:func>')
# def func(func):
#    os.system('./functions.sh "%s" > output.txt') % func
#    with open('output.txt', 'r') as file: 
#       content = file.read()
#    return Response(content, mimetype='text/plain')   

   
@app.route('/functions/<string:func>', methods=['GET'])
def run_function(func):
    command = f'bash -c "./functions.sh {func}"'
    try:
        output = subprocess.check_output(command, shell=True, text=True).strip()
        return Response(output, mimetype='text/plain')
    except subprocess.CalledProcessError as e:
        return f"Error: {e.output}", 500 


@app.route('/functions', methods=['GET'])
@app.route('/functions/', methods=['GET'])
def list_functions():
    command = f'bash -c "./functions.sh list_functions"'
    try:
        output = subprocess.check_output(command, shell=True, text=True).strip()
        return Response(output, mimetype='text/plain')
    except subprocess.CalledProcessError as e:
        return f"Error: {e.output}", 500 
app.run(debug = True)