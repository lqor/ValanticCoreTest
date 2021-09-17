global class FacadeInvalidClassException extends Exception{
    
    public FacadeInvalidClassException(Type type, Exception e) {
        this(String.format(
            'Requested class "{0}" is not a class of type "{1}"', 
            new List<Object> {type.getName(), Facade.class}
        ),e);
    }
}