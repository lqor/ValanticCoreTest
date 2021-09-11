global class FacadeNotExistsException extends Exception{
    
    public FacadeNotExistsException(Type type, String error) {
        this('Requested class is not a class of type "' + Facade.class + '". Error: ' + error);
    }
}
