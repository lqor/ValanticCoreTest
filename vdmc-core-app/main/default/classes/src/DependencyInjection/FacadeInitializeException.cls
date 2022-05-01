
public class FacadeInitializeException extends Exception{

    public FacadeInitializeException(Type type, Exception e) {
        this(String.format('Could not init  "{0}".', new List<Object>{Facade.class}), e);
    }
}
