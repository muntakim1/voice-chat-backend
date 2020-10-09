from flask import Flask,request,jsonify,redirect
from flask_restful import Api,Resource,reqparse
from flask_cors import CORS
import aiml

app = Flask(__name__)
api = Api(app)
CORS(app)
parser = reqparse.RequestParser()
parser.add_argument('text')

kernel = aiml.Kernel()
kernel.learn('./brain/brain.aiml')
listdata=[]
class ApiBot(Resource):
    
    def post(self):
        
        args = parser.parse_args()
        listdata.append(str(args['text']))
        print(listdata)       
        return {'Message':"Post data read successfully"}

    def get(self):
        if(len(listdata)!=0):
            respond= kernel.respond(listdata[-1])
            print(respond)
            listdata.clear()
            return jsonify({"respond":respond})
           
        else:
            return 204
    

api.add_resource(ApiBot, '/api/')

from app import app
if __name__=="__main__":
    app.run(host='0.0.0.0',threaded=True, port=5000)