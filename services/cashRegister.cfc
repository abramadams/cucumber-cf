component{
    function makeTransaction( price, paid ){
        if( price >= paid ){
            return "You don't have enough";
        }
        return paid - price;
    }
    function calculatePrice( price, taxable, taxRate ){
        if( !taxable ) return price;
        return price + ( price * taxRate );
    }
}