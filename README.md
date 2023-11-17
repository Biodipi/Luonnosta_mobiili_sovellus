# Luonnosta-mobiilisovellus
Luonnosta mobiilisovelluksen avulla luonnontuotteiden kerääjät voivat ilmoittaa keruupaikkansa paikkatietoon perustuen luonnontuotteiden ostajalle. Luonnontuotteiden ostaja vastaanottaa kerääjän keruumerkinnät samalla mobiilisovelluksella. Mobiilisovellus mahdollistaa myös merkinnän jakamisen pdf-raporttina. Sovelluksen tavoitteena on helpottaa luonnontuotteiden jäljitettävyyttä elintarvikeketjussa paikkatiedon avulla luodun merkinnän perusteella. Merkinnät tallentuvat sovellukseen ja niitä voidaan jakaa ostajalle tai muulle taholle joko merkinnän teon yhteydessä tai jälkikäteen. Lisätietoa ja materiaaleja löydät BioDiPi-hankkeen nettisivuilta http://www.oamk.fi/biodipi

# Sovelluksen toiminta:
Sovellukseen käyttö vaatii rekisteröitymistä. Sovellukseen rekisteröidytään omalla sähköpostiosoitteella. Jos olet unohtanut salasanasi, se voidaan palauttaa ”Unohditko salasanasi?” kohdasta.

![image](https://github.com/Biodipi/Luonnosta_mobiili_sovellus/assets/73608659/6ffa2799-117d-4fdb-bdab-698a0a752f69)

Sisään kirjauduttuasi avautuu sovelluksen päänäkymä, jossa voidaan luoda merkintä ja selailla omia merkintöjä joko ”Omat merkinnät” tai ”Kartta” näkymässä. Karttanäkymä mahdollistaa myös sovellukseen integroidun kartan selailumahdollisuuden. Sovelluksen testausvaiheessa karttapohjana toimi Maanmittauslaitoksen maksullinen WMS-karttapohja. 

![image](https://github.com/Biodipi/Luonnosta_mobiili_sovellus/assets/73608659/fbe18abc-ce4d-40e0-a9c3-48c9798175b3)

”Luo merkintä” näkymässä luodaan merkintä luonnontuotteiden keruupaikasta. Klikkaamalla ”luo merkintä” painiketta, avautuu ensimmäisenä sovelluksen karttapohja, jossa sinistä paikannuspainiketta painamalla voit asettaa sijaintisi. Sovellus voi käyttää puhelimen paikkatietoja sekä kameraa luvan annettuasi. 
Merkinnän yhteyteen voidaan puhelimen kameralla ottaa kuva kerätyistä luonnontuotteista. ”Otsikko” kohtaan voidaan kirjata kerätty luonnontuote, ja ”Lisätiedot” kohtaan voidaan kirjata keräyspäivämäärä, tietoa esimerkiksi keruupäivän säätilasta, hyttysten määrästä tai tuotteen laadusta. Kirjaamalla ”Jaettu käyttäjille” kohtaan ystäväsi tai luonnontuotteiden ostajan sähköpostiosoitteen, merkintä jaetaan kyseiselle sovellukseen kirjautuneen käyttäjän sovellukseen.

![image](https://github.com/Biodipi/Luonnosta_mobiili_sovellus/assets/73608659/bc813479-6c53-49b9-8b18-4aa320df3765)

Luotuja merkintöjä voi selailla joko ”Kartta” tai ”Omat merkinnät näkymässä. ”Kartta” näkymässä vihreät pallot tarkoittavat sinun omia tekemiäsi merkintöjä, joita et ole jakanut kenellekään. Jos olisit jakanut merkinnän, se näkyisi sinulle sinisenä. Harmaa pallo kartassa tarkoittaa sinulle jonkun muun jakamia merkintöjä. Samat värikoodit pätevät myös ”Omat merkinnät” näkymän listauksessa, joissa voit listana selailla omia ja muiden sinulle jakamia merkintöjä.

![image](https://github.com/Biodipi/Luonnosta_mobiili_sovellus/assets/73608659/e141712b-6332-44c7-9f62-b9b738344e10)

Sovelluksen Asetuksissa voidaan Kirjautua ulos sovelluksesta sekä Poistaa tili. 

![image](https://github.com/Biodipi/Luonnosta_mobiili_sovellus/assets/73608659/bad52000-f113-4aa3-b276-cd6367858b99)

# Sovelluksen toteutuksessa käytetyt tekniikat:

Sovellus on toteutettu Flutterilla. Sovellus löytyy Android-sovelluksena Googlen Play-kaupasta. Tiedot tallentuvat Firebase-tietokantaan.

# Lisenssi:

Tämän sovelluksen lähdekoodi on lisenssoitu MIT-lisenssillä. Lisenssin tarkemmat tiedot löytyvät [LICENSE](https://github.com/Biodibi/luonnosta_mobiili_sovellus/blob/master/LICENSE) tiedostosta. Mikäli sovelluksessa on käytetty kolmannen osapuolen työkaluja, komponentteja tai vastaavia, noudatetaan niiden osalta ilmoitettuja lisenssiehtoja.

# luonnosta_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
