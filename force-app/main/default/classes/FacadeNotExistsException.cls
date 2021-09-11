global class FacadeNotExistsException extends Exception{
    
    public FacadeNotExistsException(Type type) {
        this('Requested class is not a class of type "' + Facade.class + '"');
    }
}
