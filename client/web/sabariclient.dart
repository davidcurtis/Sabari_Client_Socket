//library sabariClient;
import'dart:html';
import'dart:json';

final IP = '127.0.0.1';
final PORT = 8080;


///////////////////////////////////////////////////////////

class ClientInterface 
{
  WebSocket web_sockets;
  bool etat_connection = false;
  String provenanceMessage;
  chatClientVue vue;
  chatClientControleur controleur;
 
  
  //Inscription 
  FormElement forminscription = query("#forminscription");
  InputElement nomUtilisateur2 = query("#Nom_Utilisateur2");
  InputElement motDePasse2 = query("#Mot_DePasse2");
  DivElement divInscription = query("#loginbox");
  
  
  // Envoi Message 
  FormElement envoiMessage = query("#chat_message");
  List<String> filMessage ;
  InputElement messageTexte = query("#leTexte");
  InputElement destinataireChoisi = query("#destinataire");


  ClientInterface() {
    vue = new chatClientVue();
    controleur = new chatClientControleur();
  }
  
  void initialiserWebSocket() {

    web_sockets = new WebSocket("ws://$IP:$PORT/sabariclient");
    
    web_sockets.on.open.add ((e)
        {
            print("Connection Interface etablie-+------------------------");
        });

    // Reception de message 
    web_sockets.on.message.add((MessageEvent  c) 
     {
      print("Message recue ${c.data}");
      List<String> listeRecue = c.data.toString().split(',');
      
      //Recevoir la liste des contacts
      if(listeRecue.contains('list'))
      {
        vue.afficherContact(listeRecue.last.toString());
      }
      
      
      //Recevoir un message destiné a tout le monde
      else if(listeRecue.contains('msgAll'))
      {
        vue.ajouterMessage("${listeRecue.last.toString()}:".concat(listeRecue[1].toString()));
      }
      
      
      //Recevoir un message 1 a 1
      else if(listeRecue.contains('msg'))
      {
        vue.ajouterMessage(listeRecue.last.toString());
      }
      
      //Serveur indisponible
      else if(listeRecue.contains('err'))
      {
        vue.ajouterMessage(listeRecue.last.toString());
      }
      
     
    });
    
   
  }
  
  void gestionEvenements() {
 
    // Inscription
    motDePasse2.on.keyPress.add((key)
        {
            if(key.charCode == 13)
            {
              if(nomUtilisateur2!= null && motDePasse2 != null)
              {
                
                web_sockets.send( "register,${nomUtilisateur2.value},${nomUtilisateur2.value}");
                provenanceMessage = nomUtilisateur2.value;
                vue.afficherContact(nomUtilisateur2.value);
                vue.effacerBox(nomUtilisateur2);
                vue.effacerBox(motDePasse2);
             
              }
              
            }
            
        });
    

    //Envoi message groupé
    messageTexte.on.keyPress.add((key)
        {
          if(key.charCode == 13)
          {
               if(messageTexte.value!= "" )
               {
                 print(destinataireChoisi.value.toString());
                if(destinataireChoisi.value.toString() == "")
                 {
                   String messageAEnvoyer = "msgAll,".concat(messageTexte.value.concat(",${provenanceMessage}").concat('\n'));
                   web_sockets.send(messageAEnvoyer);
                   vue.effacerBox(messageTexte);
                  
                 }
                 //Envoi un a plusieurs destinataire
                 else if(destinataireChoisi.value.toString() != "")
                 {
                   List<String>listeDestinataire = destinataireChoisi.value.split(',');
                   String messageAEnvoyer = "destinataire,".concat(listeDestinataire.toString().concat('\n'));
                   web_sockets.send(messageAEnvoyer);
                   vue.afficherMessage(messageTexte.value ,provenanceMessage );
                   vue.effacerBox(messageTexte);
                 }
                
               }
          }
        });
    
    
  }
  
  
  void run() {
    initialiserWebSocket();    
    gestionEvenements();
    etat_connection = true;
  }
}



//////////////////////////////////////////////////////////////////////


class chatClientVue 
{
 DivElement fenetreChat; 
 DivElement fenetreListClient;
 DivElement fenetreInscription;
 DivElement fenetreMessage;
 UListElement listContact ;
 
 chatClientVue() {
   fenetreChat = document.query('#conversation');
   fenetreListClient = document.query('#list_contact');
   fenetreInscription = document.query('#loginbox');
   fenetreMessage = document.query("#message");
   
  }


  void afficherMessage(String message , String provenance) {
    fenetreChat.innerHTML = "${fenetreChat.innerHTML} <br/> $provenance :  $message";
  }
  
  void afficherContact(String contact) {
   
    if(!fenetreListClient.innerHTML.contains(contact))
    {
      fenetreListClient.innerHTML = "${fenetreListClient.innerHTML} <br/> $contact";
      fenetreInscription.style.display ='none';
      fenetreChat.style.display = 'block';
      fenetreListClient.style.display ='block';
      fenetreMessage.style.display ='block';
    }
    
    
  }
  
  void affichageClientConnect(List listClient)
  {
    
    fenetreListClient.innerHTML = "${fenetreListClient.innerHTML} <br/> $listClient";
  }
 
  void effacerBox(InputElement elementAEffacer) {
    elementAEffacer.value = "";
    }
  
  void effacerContact(DivElement elementAEffacer) 
  {
    elementAEffacer.elements.clear();
  }
    
  void effaceDiv(DivElement div )
  {
    div.style.display ='none';
  }
  
  void ajouterMessage(String messageRecue)
  {
    var nouveauMessage = new LIElement();
    nouveauMessage.text = messageRecue;
    fenetreChat.elements.add(nouveauMessage);
  }

}
////////////////////////////////////////////////////////////////////

class chatClientControleur
{
  
  chatClientControleur() {
  }

  // Envoi message
  void envoiMessage(WebSocket ws, String message ,String destinataire) {
    if (!message.isEmpty)
    {
      ws.send(JSON.stringify({"cmd": "msg", "leMessage": message , "destinataire":destinataire}));
      
    }
  }
}

//////////////////////////////////////////////////////////////

void main() {
  
 
  ClientInterface newClient = new ClientInterface();
  newClient.run();
 
}




