class Television{
  void turnOn() {
    _illuminateDisplay();
  }

  void _illuminateDisplay(){

  }
}
class Update{
  void updateApp(){

  }
}
class Charge{
  void chargeVip(){

  }
}
class SmartTelevision extends Television with Update,Charge{

  @override
  void turnOn() {
    _bootNetworkInterface();
    updateApp();
    chargeVip();
  }
  void _bootNetworkInterface(){

  }
}