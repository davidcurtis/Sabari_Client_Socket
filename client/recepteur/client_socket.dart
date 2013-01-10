import'dart:io';
import'dart:json';

final IP = '127.0.0.1';
final PORT = 8080;

class ClientSocket {
  StringInputStream entreeServeur;
  OutputStream outputStream;
  WebSocketConnection socketInterface;
  String messageAEnvoyer;
  //----------------------------------- Ecrivez l'addresse Ip de votre serveur juste en bas ! ------------------------------
  Socket conn = new Socket("", 8080);
  String messageRecueDuServeur='';
  int incrementationMessage =0 ;
  
  
  ClientSocket()
  { 

 
   }
  
  void socketServeurConnection()
  {
    StringInputStream inputStr;
    OutputStream outputStream;

    conn.onConnect = () {
      print("Now Connected");
      
      inputStr = new StringInputStream(conn.inputStream);
      outputStream = conn.outputStream;
      

      inputStr.onLine = () {
        String input = inputStr.readLine();
        print("Recieved: $input\n");
        messageRecueDuServeur = input;  
        setReception();
        
      };

      inputStr.onClosed = () {
        print("*********************  Serveur distant absent  ******************************");
        ServeurDistantIndisponible();
        conn.close();
      };
    };
  }

  void envoiMessageServeur (String Message)
  {
    outputStream = conn.outputStream;
    outputStream.write(Message.charCodes);
  }
  void setReception([int retrySeconds = 1])
  {
     if(messageRecueDuServeur!= '')
     {
       socketInterface.send(messageRecueDuServeur);
       messageRecueDuServeur = '';
     }
  }
  void ServeurDistantIndisponible([int retrySeconds = 1])
  {
     
       socketInterface.send("err,*********************  Serveur distant absent  ******************************");
    
    
  }
}
void main()
{
  ClientSocket Client = new ClientSocket();
  
  Client.socketServeurConnection();
  
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  server.addRequestHandler((req) => req.path == "/sabariclient", wsHandler.onRequest);
  
  server.addRequestHandler((req) => req.path == "/", (HttpRequest req, HttpResponse res) {
    File file = new File("../client/sabariclient.html"); 
    file.openInputStream().pipe(res.outputStream); 
  });
  server.addRequestHandler((req) => req.path == "/sabariclient.html", (HttpRequest req, HttpResponse res) {
    File file = new File("../client/sabariclient.html"); 
    file.openInputStream().pipe(res.outputStream); 
  });
  server.addRequestHandler((req) => req.path == "/sabariclient.dart", (HttpRequest req, HttpResponse res) {
    File file = new File("../client/web/sabariclient.dart"); 
    file.openInputStream().pipe(res.outputStream); 
  });
  server.addRequestHandler((req) => req.path == "/sabariclient.dart.js", (HttpRequest req, HttpResponse res) {
    File file = new File("../client/sabariclient.dart.js"); 
    file.openInputStream().pipe(res.outputStream); 
  });
  
  
  wsHandler.onOpen = (WebSocketConnection conn) {
  
    Client.socketInterface = conn ;
    print("Connection interface etablie ");
    
    Client.socketInterface.onMessage = (Message)
    {
      print("Message recue:${Message}");
      String envoiAuServeur = "${Message}\n";
      Client.envoiMessageServeur(envoiAuServeur);
      print("Message envoyé au serveur :${Message}");
     
      
    };
    
  };
  
  server.listen(IP,PORT);



}

